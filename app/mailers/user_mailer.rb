class UserMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def user_email(email,first_name,message_text,action_array)
    @first_name  = first_name
    @message_text = message_text
    @action_array = action_array
    mail(to: email, subject: "We sent a message on your behalf")
  end
end
