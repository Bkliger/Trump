class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,civic_reps,sunlight_reps)
    @salutation  = salutation
    @title = title
    @message_text = message_text
    if sunlight_reps == "xxx"
      @civic_reps = civic_reps
    else
      @sunlight_reps = sunlight_reps
    end
    mail(to: email, subject: title)
  end
end
