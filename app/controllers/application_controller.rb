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
  # get a response and convert the hash (JSON) into an object
  res = JSON.parse(response, object_class: OpenStruct)
end
