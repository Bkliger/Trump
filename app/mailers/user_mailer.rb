class UserMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def user_email(email,first_name,message_text)
    @first_name  = first_name
    @message_text = message_text
    mail(to: email, subject: "We sent a message on your behalf")
  end
end
