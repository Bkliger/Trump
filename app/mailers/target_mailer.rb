class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,civic_reps,sunlight_reps,action_array,target_id,base_url)
    @salutation  = salutation
    @title = title
    @message_text = message_text
    @action_array = action_array
    @target_id = target_id
    @base_url = base_url




    mail(to: email, subject: title)
  end
end
