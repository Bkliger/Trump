
class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_filter :set_cache_headers

    # this redirects devise after sign in
    # def after_sign_up_path_for(resource)
    #   binding.pry
    #     targets_path
    # end

    def after_sign_in_path_for(resource)
        targets_path
    end

    require 'net/http'
    # library to handle JSON
    require 'json'
    # used to create an object from a hash
    require 'ostruct'
    # used to process the xml from the usps api
    require 'rexml/document'

    def create_single_message(user, target, message, request_origin)
        get_url
        if target.status == 'Active' && target.contact_method == "email_val"
            lookup_reps(target, request_origin)
            # send an email to each target
            TargetMailer.target_email(target.email, target.salutation, message.title, message.message_text, @civic_reps, @sunlight_reps, @action_array, target.id, @base_url, target.zip, @zip4).deliver_now

            # create a target message for each message sent to a target
            targmess = Targetmessage.new do |m|
                m.sent_date = Date.today
                m.message_text = message.message_text
                m.user_id = target.user_id
                m.target_id = target.id
            end
            targmess.save
            # send email to the user
            UserMailer.user_email(user.email, user.first_name, targmess.message_text, @action_array).deliver_now
        elsif target.status == 'Active' && target.contact_method == "text_val"
            lookup_reps(target, request_origin)
            send_twilio(message,target)
        end
    end

    def lookup_reps(target, request_origin)
        @action_array = [] # builds the action block for the email
        if !target.zip.blank?
        # zip entered
            main_zip_processing(target,request_origin)
        # no zip and only state
      elsif (target.zip.blank? && (target.address.blank? && target.city.blank?))
            state_processing(target,request_origin)
        # no zip and full address
      elsif (target.zip.blank? && (!target.address.blank? || !target.city.blank?))
            full_address_processing(target,request_origin)
        end

        # decide what page to display based on the process that requested this method
        if request_origin == 'finish'

            return
        elsif request_origin == 'bulk send'
            return
        elsif request_origin == 'update_step_1'

            flash[:notice] = nil
            render :step_two
        elsif request_origin == 'update_step_2'

            flash[:notice] = nil
            render :step_three
        else

            flash[:notice] = nil
            render :step_two
        end
    end

    def main_zip_processing(target,request_origin)
        @sunlight_reps = sunlight_api(target.zip)
        determine_rep_stats_sunlight(@sunlight_reps.results)
        if @republican_count == 0
            congressional_stats = {senator_count: 0, rep_count: 0}
            @action_array.unshift(congressional_stats)
            @target_message = %q[You can add this person even though they won't receive messages at this time.]
            @more_info_needed = 0
            @status = 'No Republicans'
        # elsif @last_state != target.state
        #     @target_message = 'The state entered does not match the zip code.'
        #     @more_info_needed = 2
        #     @status = 'Incomplete"
        elsif @total_representative_count > 1
            @action_array = [] # reinitialize the array that builds the action block for the email
              @target_message = %q[We found more than one representative for this Zip Code. Enter an address if you would like us to select the representative.]
            # if you have the full address
            if !target.address.blank? && !target.city.blank?
                full_address_processing(target,request_origin)
            # if you only have the state
            else
                state_processing(target,request_origin)
            end
        else
            congressional_stats = {senator_count: @senator_count, rep_count: @rep_count}
            @action_array.unshift(congressional_stats)
            @more_info_needed = 0
            @status = 'Active'
        end
    end

    def full_address_processing(target,request_origin)
        usps_lookup(target.address,target.city,target.state)
        if @bad_address == true
            @target_message_1 = 'Address not found. '
            @more_info_needed = 0
            @status = 'Incomplete'
            state_processing(target,request_origin)
        else
            address = target.address + ' ' + target.city + ' ' + target.state
            @republican_count = 0
            civic_response = civic_api(address)
            if !civic_response.error.nil?
                @target_message = 'No Information for this address'
                @more_info_needed = 1
                @status = 'Incomplete'

            else
                @senator_count = 0
                @rep_count = 0
                @civic_reps = civic_api(address).officials[2, 3]
                determine_rep_stats_civic(@civic_reps)

                if @republican_count > 0
                    congressional_stats = {senator_count: @senator_count, rep_count: @rep_count}
                    @action_array.unshift(congressional_stats)
                    @target_message = ""
                    @more_info_needed = 0
                    @status = 'Active'
                else
                    congressional_stats = {senator_count: 0, rep_count: 0}
                    @action_array.unshift(congressional_stats)
                    @target_message = 'There are no Republican Senators or Representatives for this person.'
                    @more_info_needed = 0
                    @status = 'No Republicans'
                end
            end
        end
    end

    def state_processing(target,request_origin)
        address = target.state
        @republican_count = 0
        civic_response = civic_api(address)
        @senator_count = 0
        @rep_count = 0
        @civic_reps = civic_response.officials[2, 2]
        determine_rep_stats_civic(@civic_reps)
        if @republican_count > 0
          congressional_stats = {senator_count: @senator_count, rep_count: @rep_count}
          @action_array.unshift(congressional_stats)
            if !@target_message_1.nil?
                @target_message = @target_message_1 + 'Optionally, add a valid address for this person to see if they also have a Republican Congressperson.'
            else @target_message = 'Optionally, add a valid address for this person to see if they also have a Republican Congressperson.'
            end
            @more_info_needed = 1
            @status = 'Active'
        else
            congressional_stats = {senator_count: 0, rep_count: 0}
            @action_array.unshift(congressional_stats)
            @target_message = 'Optionally, add an address for this person to see if they also have a Republican Congressperson.'
            @more_info_needed = 1
            @status = 'No Republicans'
        end
        if !@total_representative_count.nil?
            if @total_representative_count > 1
                @target_message = %q[We found more than one representative for this Zip Code. Enter an address if you would like us to select the representative.]
            end
        end
    end

    def build_action_array_civic(r,rep_type)
        last_name = parse_rep_name_civic(r.name)
        rep = Rep.where(first_three: r.name.slice(0,3), last_name: last_name)
        action_item = {}
        if rep[0].url.nil?
            action_item = { rep_name: r.name, rep_phone: r.phones[0], rep_type: rep_type }
        else
            action_item = { rep_name: r.name, rep_phone: r.phones[0], rep_type:rep_type, rep_email: rep[0].url }
        end
        @action_array << action_item
    end

    def build_action_array_sunlight(r,rep_type)
        rep = Rep.where(first_three: r.first_name.slice(0,3), last_name: r.last_name)
        full_name = r.first_name + ' ' + r.last_name
        action_item = {}
        if rep[0].url.nil?
            action_item = { rep_name: full_name, rep_phone: r.phone, rep_type: rep_type }
        else
            action_item = { rep_name: full_name, rep_phone: r.phone, rep_email: rep[0].url, rep_type: rep_type  }
        end
        @action_array << action_item

    end

    def send_twilio(message,target)
        require 'rubygems' # not necessary with ruby 1.9 but included for completeness
        require 'twilio-ruby'
        text_message = build_text_message(message)

        formatted_phone_number = "+1" + target.phone.gsub!(/\D/, '')

        # put your own credentials here
        account_sid = ENV['TWILIO_ACCOUNT_SID']
        auth_token = ENV['TWILIO_AUTH_TOKEN']

        # set up a client to talk to the Twilio REST API
        @client = Twilio::REST::Client.new(account_sid, auth_token)

        @twillio_message = @client.account.messages.create(
            from: ENV['TWILIO_NUMBER'],
            to: formatted_phone_number,
            body: text_message
        )

        puts @twillio_message.subresource_uris
    end

    def format_USPS(address, city, state)
        base_USPS_url = 'http://production.shippingapis.com/ShippingAPI.dll?API=ZipCodeLookup&XML=<ZipCodeLookupRequest%20USERID='
        user_id = ENV['USPS_USER']
        xml_1 = '<Address> <Address1></Address1> <Address2>'
        xml_2 = '</Address2><City>'
        xml_3 = '</City><State>'
        xml_4 = '</State></Address></ZipCodeLookupRequest>'
        xml_string = base_USPS_url + "\"" + user_id + "\">" + xml_1 + address + xml_2 + city + xml_3 + state + xml_4
    end

    def get_url
        require 'uri'
        uri = request.original_url
        uri = URI.parse(request.original_url)
        if uri.port.blank?
            @base_url = uri.scheme.to_s + '://' + uri.host.to_s
        else
            @base_url = uri.scheme.to_s + '://' + uri.host.to_s + ':' + uri.port.to_s
        end
    end

    def parse_rep_name_civic(name)
      i = -1
      spaces = []
      while i = name.index(' ',i+1)
        spaces << i
      end
      last_name = name[spaces.last+1, (name.length - spaces.last - 1)]

    end

    def determine_rep_stats_civic(civic_reps)
        result_count = 1
        civic_reps.each do |r|
            if (result_count < 3)
                rep_type = "S"
            else
                rep_type = "R"
            end
            result_count += 1
            if r.party == 'Republican'
                @republican_count += 1
                if rep_type == "S"
                    @senator_count += 1
                else
                    @rep_count += 1
                end
                build_action_array_civic(r,rep_type)
            end
        end
    end

    def determine_rep_stats_sunlight(sunlight_reps)
        @republican_count = 0
        @total_representative_count = 0
        @rep_count = 0
        @senator_count = 0
        sunlight_reps.each do |r|
            if r.chamber == "house"
                rep_type = "R"
                @total_representative_count += 1
                if r.party == 'R'
                    @republican_count += 1
                    @rep_count += 1
                    build_action_array_sunlight(r,rep_type)
                end
            else
                if r.party == 'R'
                    @republican_count += 1
                    rep_type = "S"
                    @senator_count += 1
                    build_action_array_sunlight(r,rep_type)
                end
            end
            @last_state = r.state
        end
    end

    def usps_lookup(address,city,state)
        url = format_USPS(address, city, state)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        if !response.include? 'Error'

            # get rid of the front part of the response
            response.slice! "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            document = REXML::Document.new(response)
            @zip4 = REXML::XPath.first(document, '/ZipCodeLookupResponse/Address/Zip4/text()').to_s
            @zip5 = REXML::XPath.first(document, '/ZipCodeLookupResponse/Address/Zip5/text()').to_s

        else
            @bad_address = true
            @zip4 = 'Error'
        end
    end

    #--------------------------APIs------------------------------------

    def sunlight_api(zip)
        # construct the url
        url = 'https://congress.api.sunlightfoundation.com/legislators/locate?zip=' + zip
        # call the url using the net/http structure
        uri = URI(url)
        response = Net::HTTP.get(uri)
        # get a response and convert the hash (JSON) into an object
        res = JSON.parse(response, object_class: OpenStruct)
    end

    def civic_api(address)
        # construct the url
        url = 'https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyBH9gjtOwvfkbDqxLoFdbfcR2tB978ETew&address=' + address
        # call the url using the net/http structure
        uri = URI(url)
        response = Net::HTTP.get(uri)
        res = JSON.parse(response, object_class: OpenStruct)
    end

    def build_text_message(message)
        message_array = []
        message_array << message.text_message
        @action_array[1,@action_array.length-1].each do |r|
            message_array << r[:rep_name]
            message_array << r[:rep_phone]
        end
        message_array.to_sentence
    end
    private

    def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

end
