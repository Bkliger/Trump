
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





  def sunlight_api(zip)
      # construct the url
      url = 'https://congress.api.sunlightfoundation.com/legislators/locate?zip=' + zip.to_s
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

  def create_single_message(user, target, message,request_origin)
      lookup_reps(target,request_origin)
      # send an email to each target
      TargetMailer.target_email(target.email, target.salutation, message.title, message.message_text, @civic_reps, @sunlight_reps, @action_array).deliver_now
      #test twilio


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

  def lookup_reps(target,request_origin)
    @action_array = [] #builds the action block for the email
    case
    # zip is blank and state is blank
    when (target.zip.blank? && target.state.blank?)
        @target_message = 'State is required'

    # zip is not blank
    when (!target.zip.blank?)
        republican_count = 0
        representative_count = 0
        @sunlight_reps = sunlight_api(target.zip)
        if @sunlight_reps.results == []

            @target_message = 'Invalid Zip Code'
            status = "Incomplete"
        else
            @sunlight_reps.results.each do |r|
                representative_count += 1
                next unless r.party == 'R'
                republican_count += 1
                build_action_array_sunlight(r)
            end
            if republican_count == 0
                @target_message = 'There are no Republican Senators or Representatives for this person.'
                status = "No Republicans"
            elsif representative_count > 3
              puts "more than three"
                @action_array = [] #reinitialize the array that builds the action block for the email
                # if you have the full address
                if !target.address.blank? && !target.city.blank? && !target.state.blank?
                    address = target.address + ' ' + target.city + ' ' + target.state
                    puts "with full address"
                    republican_count = 0
                    @civic_reps = civic_api(address).officials[2, 3]
                    if @civic_reps == []
                      @target_message = 'No Information for this address'
                      status = "Incomplete"
                    else
                      @civic_reps.each do |r|
                          republican_count += 1 if r.party == 'Republican'
                          build_action_array_civic(r)
                      end
                      if republican_count > 0
                          @target_message = 'Congresspeople found.'
                          status = "Active"
                      else
                          @target_message = 'There are no Republican Senators or Representatives for this person.'
                          status = "No Republicans"
                      end
                    end
                # if you only have the state
                elsif (target.address.blank? || target.city.blank?) && !target.state.blank?
                    address = target.state
                    @civic_reps = civic_api(address).officials[2, 2]
                    @civic_reps.each do |r|
                        republican_count += 1 if r.party == 'Republican'
                        build_action_array_civic(r)
                    end
                    if republican_count > 0
                        @target_message = 'More than 1 representative found. We will target Senators unless you add the full address.'
                        status = "Incomplete"
                    else
                        @target_message = 'There are no Republican Senators for this person. We can check for representatives if you enter the full address.'
                        status = "Incomplete"
                    end
                else
                    @target_message = 'More than 1 representative found. Click the back button and enter the state at a minimum.'
                    status = "Incomplete"
                end

            else
                @target_message = 'Congresspeople found'
                status = "Active"
            end
        end
    # no zip and only state
    when (target.zip.blank? && (target.address.blank? || target.city.blank?) && !target.state.blank?)
        address = target.state
        republican_count = 0
        civic_response = civic_api(address)
        if !civic_response.error.nil?
            @target_message = 'No Information for this address'
            status = "Incomplete"
        else
            @civic_reps = civic_response.officials[2, 2]
            @civic_reps.each do |r|
                republican_count += 1 if r.party == 'Republican'
            end
            if republican_count > 0
                @target_message = 'Republican Senators found. If you know the address, we can check for representatives.'
                status = "Active"
            else
                @target_message = 'There are no Republican Senators. If you know the address, we can check for representatives.'
                status = "No Republicans"
            end
        end
    # no zip and full address
    when (target.zip.blank? && !target.address.blank? && !target.city.blank? && !target.state.blank?)
        address = target.address + ' ' + target.city + ' ' + target.state
        republican_count = 0
        if !civic_api(address).error.nil?
            @target_message = 'No Information for this address'
            status = "Incomplete"

        else
            @civic_reps = civic_api(address).officials[2, 3]
            @civic_reps.each do |r|
                republican_count += 1 if r.party == 'Republican'
                build_action_array_civic(r)
            end
            if republican_count > 0
                @target_message = 'Congresspeople found.'
                status = "Active"

            else
                @target_message = 'There are no Republican Senators or Representatives for this person.'
                status = "No Republicans"

            end
        end

    #extra conditions that I haven't thought through
    when (!target.zip.blank? && target.state.blank?)
        puts 'zip is entered but state is blank'
    when (!target.zip.blank? && !target.state.blank?)
        puts 'zip is entered and state is entered'
    end

    if request_origin == "finish"
      return

    elsif request_origin == "bulk send"
      return
    else
      @target.update(status: status)
      render 'target_message'

    end

  end

  def build_action_array_civic(r)
    action_item = {}
    if r.emails.nil?
      action_item = { rep_name: r.name, rep_phone: r.phones[0] }
    else
      action_item = { rep_name: r.name, rep_phone: r.phones[0], rep_email: r.email[0] }
    end
    puts "array"
    puts @action_array << action_item

  end

  def build_action_array_sunlight(r)
      full_name = r.first_name + ' ' + r.last_name
      action_item = {}
      if r.oc_email.nil?
          action_item = { rep_name: full_name, rep_phone: r.phone }
      else
          action_item = { rep_name: full_name, rep_phone: r.phone, rep_email: r.oc_email }
      end
      puts @action_array << action_item
  end

  # def test_twilio
  #   @twilio_number = ENV['TWILIO_NUMBER']
  #     @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  #     # time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d, %Y")
  #     reminder = "Hi Joe. Just a reminder that you have an appointment coming up at."
  #     message = @client.account.messages.create(
  #       :from => @twilio_number,
  #       :to => 9252867453,
  #       # :to => self.phone_number,
  #       :body => reminder,
  #     )
  #     puts message.to
  # end

  private



end
