class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,reps)
    # @user = user
    @salutation  = salutation
    @title = title
    @message_text = message_text
    @reps = reps
    mail(to: email, subject: title)
  end
end

# target.email,target.salutation,@message.title,@message.message_text
