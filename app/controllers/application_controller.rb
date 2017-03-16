
class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # this redirects devise after sign in
    def after_sign_in_path_for(_resource)
        targets_path
    end

    require 'net/http'
    # library to handle JSON
    require 'json'
    # used to create an object from a hash
    require 'ostruct'
    # used to process the xml from the usps api
    require 'rexml/document'

    def usps_lookup(target)
        url = format_USPS(target.address, target.city, target.state)
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

    def create_single_message(user, target, message, request_origin)
        # test_twilio
        get_url
        if target.status == 'Active'
            lookup_reps(target, request_origin)
            # send an email to each target
            TargetMailer.target_email(target.email, target.salutation, message.title, message.message_text, @civic_reps, @sunlight_reps, @action_array, target.id, @base_url, target.zip, @zip4).deliver_now

            # test twilio

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
        end
    end

    def lookup_reps(target, request_origin)
        @action_array = [] # builds the action block for the email
        if !target.zip.blank?
        # zip entered
            @action_array = [] # builds the action block for the email
            @sunlight_reps = sunlight_api(target.zip)
            if @sunlight_reps.results == []
                @target_message = 'Invalid Zip Code'
                @status = 'Incomplete'
            else
                # if you have the full address
                if !target.address.blank? && !target.city.blank?
                    full_address_processing(target,request_origin)
                else
                    main_zip_processing(target,request_origin)
                end
            end
        # no zip and only state
        elsif (target.zip.blank? && (target.address.blank? || target.city.blank?))
            state_processing(target,request_origin)
        # no zip and full address
        elsif (target.zip.blank? && !target.address.blank? && !target.city.blank?)
            full_address_processing(target,request_origin)
        end
        # decide what page to display based on the process that requested this method
        if request_origin == 'finish'
            return
        elsif request_origin == 'bulk send'
            return
        else
            target.update(status: @status)
            render 'target_message'
        end
    end

    def main_zip_processing(target,request_origin)
        republican_count = 0
        representative_count = 0
        @sunlight_reps.results.each do |r|
            representative_count += 1
            next unless r.party == 'R'
            republican_count += 1
            build_action_array_sunlight(r,request_origin)
            @last_state = r.state
        end
        if republican_count == 0
            @target_message = 'There are no Republican Senators or Representatives for this person.'
            @status = 'No Republicans'
            binding.pry
        elsif representative_count > 3
            if @last_state != target.state
                @target_message = 'More than 1 representative found for this zip code and the state entered does not match the zip code. Click the back button to enter the correct state and/or full address.'
                @status = 'Incomplete'
            else
                @action_array = [] # reinitialize the array that builds the action block for the email
                # if you have the full address
                if !target.address.blank? && !target.city.blank?
                    full_address_processing(target,request_origin)
                # if you only have the state
                elsif target.address.blank? || target.city.blank?
                    state_processing(target,request_origin)
                else
                    @target_message = 'More than 1 representative found for this zip code. Click the back button and enter a full address if you know it.'
                    @status = 'Incomplete'
                end
            end
        else
            @target_message = 'Congresspeople found. Ready to send messages.'
            @status = 'Active'
        end
    end

    def full_address_processing(target,request_origin)
        usps_lookup(target)
        if @bad_address == true
            @target_message = 'Address not found. If you just enter the state, we can do a limited search'
            @status = 'Incomplete'
        else
            address = target.address + ' ' + target.city + ' ' + target.state
            republican_count = 0
            civic_response = civic_api(address)
            if !civic_response.error.nil?
                @target_message = 'No Information for this address'
                @status = 'Incomplete'
            else
                @civic_reps = civic_api(address).officials[2, 3]
                @civic_reps.each do |r|
                    republican_count += 1 if r.party == 'Republican'
                      build_action_array_civic(r,request_origin)
                end
                if republican_count > 0
                    @target_message = 'Congresspeople found. Ready to send messages.'
                    @status = 'Active'
                    # @zip4 =
                else
                    @target_message = 'There are no Republican Senators or Representatives for this person.'
                    @status = 'No Republicans'
                end
            end
        end
    end

    def state_processing(target,request_origin)
        address = target.state
        republican_count = 0
        civic_response = civic_api(address)
        @civic_reps = civic_response.officials[2, 2]
        @civic_reps.each do |r|
            republican_count += 1 if r.party == 'Republican'
            build_action_array_civic(r,request_origin)
        end
        if republican_count > 0
            @target_message = 'Republican Senators found. If you know the full address, we can check for representatives.'
            @status = 'Active'
        else
            @target_message = 'There are no Republican Senators. If you know the address, we can check for representatives.'
            @status = 'No Republicans'
        end
    end

    def build_action_array_civic(r,request_origin)
      if request_origin == "finish" || request_origin == "bulk send"
          last_name = parse_rep_name_civic(r.name)
          rep = Rep.where(first_three: r.name.slice(0,3), last_name: last_name)
          action_item = {}
          if rep[0].url.nil?
              action_item = { rep_name: r.name, rep_phone: r.phones[0] }
          else
              action_item = { rep_name: r.name, rep_phone: r.phones[0], rep_email: rep[0].url }
          end

          @action_array << action_item
      else
          @action_array = []
      end
    end

    def build_action_array_sunlight(r,request_origin)
        if request_origin == "finish" || request_origin == "bulk send"
            rep = Rep.where(first_three: r.first_name.slice(0,3), last_name: r.last_name)
            full_name = r.first_name + ' ' + r.last_name
            action_item = {}
            if rep[0].url.nil?
                action_item = { rep_name: full_name, rep_phone: r.phone }
            else
                action_item = { rep_name: full_name, rep_phone: r.phone, rep_email: rep[0].url }
            end
            @action_array << action_item
        else
            @action_array = []
        end
    end

    def test_twilio
        require 'rubygems' # not necessary with ruby 1.9 but included for completeness
        require 'twilio-ruby'

        # put your own credentials here
        account_sid = 'AC0ab0239d385f156c88112555be5c69c5'
        auth_token = 'ada5d72c16ee2a0ec406de3d45070da3'

        # set up a client to talk to the Twilio REST API
        @client = Twilio::REST::Client.new(account_sid, auth_token)

        @message = @client.account.messages.create(
            from: '9253784055',
            to: '9252867453',
            body: 'This is the ship that made the Kessel Run in fourteen parsecs?',
            media_url: 'https://c1.staticflickr.com/3/2899/14341091933_1e92e62d12_b.jpg'
        )

        puts @message.subresource_uris
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

    private
end
