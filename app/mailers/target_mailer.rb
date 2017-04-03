class TargetMailer < ApplicationMailer
  default from: 'bkliger@comcast.net'

  def target_email(email,salutation,title,message_text,civic_reps,sunlight_reps,action_array,target_id,base_url,zip,zip4,first_name,last_name)
    @salutation  = salutation
    @title = title
    @message_text = message_text
    @action_array = action_array
    @target_id = target_id
    @base_url = base_url
    subject = first_name + " " + last_name + " has sent you a message"
    if zip4 == "Error" || zip.blank? ||zip4.nil?
      @zipPlus4 = "Error"
    else
      @zipPlus4 = zip + "-" + zip4
    end
    mail(to: email, subject: subject)
  end
end
