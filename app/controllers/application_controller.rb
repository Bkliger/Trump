class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


# this redirects devise after sign in
  def after_sign_in_path_for(resource)
    targets_path
  end
end

require "net/http"
# library to handle JSON
require "json"
# used to create an object from a hash
require 'ostruct'

def sunlight_api(zip)
  # construct the url
  url = "https://congress.api.sunlightfoundation.com/legislators/locate?zip=" + zip.to_s
  # call the url using the net/http structure
  uri = URI(url)
  response = Net::HTTP.get(uri)
  # get a response and convert the hash (JSON) into an object
  res = JSON.parse(response, object_class: OpenStruct)
end


def civic_api(address)
  # construct the url
  url = "https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyBH9gjtOwvfkbDqxLoFdbfcR2tB978ETew&address=" + address
  # call the url using the net/http structure
  uri = URI(url)
  response = Net::HTTP.get(uri)
  res = JSON.parse(response, object_class: OpenStruct)
end

def create_single_message(user,target,message)
    if (target.address.blank? or target.city.blank?) and !target.state.blank?
      address = target.state
      @civic_reps = civic_api(address).officials[2,2] #function in application_controller
      @sunlight_reps = "xxx" #this forces the decision to use civic_reps in TargetMailer
    else
      zip = target.zip
      @sunlight_reps = sunlight_api(zip) #function in application_controller
    end
    # send an email to each target
    TargetMailer.target_email(target.email,target.salutation,message.title,message.message_text,@civic_reps,@sunlight_reps).deliver_now
# create a target message for each message sent to a target
    targmess = Targetmessage.new do |m|
      m.sent_date = Date.today
      m.message_text = message.message_text
      m.user_id = target.user_id
      m.target_id = target.id
    end
    targmess.save
    #send email to the user
    UserMailer.user_email(user.email,user.first_name,targmess.message_text).deliver_now

end

def lookup_reps
  case
  # zip is blank and state is blank
  when (target_params[:zip].blank? and target_params[:state].blank?)
    @target_message = "State is required"
    render "target_message"
  #zip is not blank
  when (!target_params[:zip].blank?)
    republican_count = 0
    representative_count = 0
    @sunlight_reps = sunlight_api(@target.zip)
    if @sunlight_reps.results == []

      @target_message = "Invalid Zip Code"
    else
      action_array = []
      @sunlight_reps.results.each do |r|

        representative_count = representative_count + 1
        if r.party == "R"
          republican_count = republican_count + 1
          action_item = {}
          if r.emails.nil?
            action_item = {rep_name: r.name, rep_phone: r.phones[0]}
          else
            action_item = {rep_name: r.name, rep_phone: r.phones[0], rep_email: r.email[0]}
          end
          action_array << action_item
        end
      end
      if republican_count == 0
          @target_message = "There are no Republican Senators or Representatives for this person."
      elsif representative_count > 3
        # if you have the full address
          if (!target_params[:address].blank? and !target_params[:city].blank? and !target_params[:state].blank?)
            address = @target.address + " " + @target.city + " " + @target.state
            republican_count = 0
            @civic_reps = civic_api(address).officials[2,2]
            @civic_reps.each do |r|
              if r.party == "Republican"
                republican_count = republican_count + 1
              end
            end
            if republican_count > 0
              @target_message = "Congresspeople found."
            else
              @target_message = "There are no Republican Senators or Representatives for this person."
            end
          #if you only have the state
          elsif ((target_params[:address].blank? or target_params[:city].blank?) and !target_params[:state].blank?)
            address = @target.state
            @civic_reps = civic_api(address).officials[2,2]
            @civic_reps.each do |r|
              if r.party == "Republican"
                republican_count = republican_count + 1
              end
            end
            if republican_count > 0
              @target_message = "More than 1 representative found. Click the back button and enter the full address"
            else
              @target_message = "There are no Republican Senators or Representatives for this person."
            end
          else
              @target_message = "More than 1 representative found. Click the back button and enter the full address"
          end

      else
          @target_message = "Congresspeople found"
      end
    end
    render "target_message"
  #no zip and only state
  when (target_params[:zip].blank? and (target_params[:address].blank? or target_params[:city].blank?) and !target_params[:state].blank?)
    address = @target.state
    republican_count = 0
    civic_response = civic_api(address)
    if !civic_response.error.nil?
      @target_message = "No Information for this address"
    else
      @civic_reps = civic_response.officials[2,2]
      @civic_reps.each do |r|
        if r.party == "Republican"
          republican_count = republican_count + 1
        end
      end
      if republican_count > 0
        @target_message = "Republican Senators found. If you know the address, we can check for representatives."
      else
        @target_message = "There are no Republican Senators. If you know the address, we can check for representatives."
      end
    end
    render "target_message"
  #no zip and full address
  when (target_params[:zip].blank? and !target_params[:address].blank? and !target_params[:city].blank? and !target_params[:state].blank?)
    address = @target.address + " " + @target.city + " " + @target.state
    republican_count = 0
    if !civic_api(address).error.nil?
      @target_message = "No Information for this address"
    else
      @civic_reps = civic_api(address).officials[2,2]
      @civic_reps.each do |r|
        if r.party == "Republican"
          republican_count = republican_count + 1
        end
      end
      if republican_count > 0
        @target_message = "Congresspeople found."
      else
        @target_message = "There are no Republican Senators or Representatives for this person."
      end
    end
    render "target_message"
  when (!target_params[:zip].blank? and target_params[:state].blank?)
    puts "zip is entered but state is blank"
  when (!target_params[:zip].blank? and !target_params[:state].blank?)
    puts "zip is entered and state is entered"
  end

end
