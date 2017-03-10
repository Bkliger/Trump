class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,civic_reps,sunlight_reps,action_array)
    @salutation  = salutation
    @title = title
    @message_text = message_text
    @action_array = action_array
    mail(to: email, subject: title)
  end
end
