class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,civic_reps,sunlight_reps,action_array,target_id,base_url,zip,zip4)
    @salutation  = salutation
    @title = title
    @message_text = message_text
    @action_array = action_array
    @target_id = target_id
    @base_url = base_url
    if !zip.blank?
      @zipPlus4 = zip + "-" + zip4
    else
      @zipPlus4 = zip4
    end
    mail(to: email, subject: title)
  end
end
