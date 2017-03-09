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
    # UserMailer.user_email(user.email,user.first_name,targmess.message_text).deliver_now

end
