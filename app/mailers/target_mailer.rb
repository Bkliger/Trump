class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def welcome_email
    # @user = user
    @url  = 'http://example.com/login'
    mail(to: "bkliger@comcast.net", subject: 'Welcome to My Awesome Site')
  end
end
