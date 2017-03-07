class MessagesController < ApplicationController
  def index
    @messages = Message.all.order("create_date DESC")
  end

  def edit
    @message = Message.find(params[:message_id])
  render :edit
  end

  def copy
    @org = Org.first
    @message = Message.find params[:message_id]
    puts @message.title
    copy_message = Message.new do |m|
      m.title = @message.title + " copy"
      m.message_text = @message.message_text
      m.org_id = @org.id
      m.create_date = Date.today
    end
    copy_message.save
    redirect_to messages_path
  end

  def new
    @message = Message.new
    @org = Org.first
    render :new
  end

  def create

    @message = Message.create(message_params)
    redirect_to messages_path
  end

  def update
    message_sent = Messhistory.where(message_id: params[:message_id]).exists?
    if message_sent
        flash[:notice] = "Messages cannot be changed if they have been sent"
    else
      @message = Message.find params[:message_id]
      @message.update(message_params)
      flash[:notice] = "Message updated"
    end
    redirect_to messages_path
  end

  def send_message

    require "net/http"
    # library to handle JSON
    require "json"
    # used to create an object from a hash
    require 'ostruct'


    # res.officials[0..8].each do |n|
    #   puts n.name
    # end

    @message = Message.find params[:message_id]
    # this is a solution for a single org. this can be expanded when other organizations can create messages
    main_org = Org.find_by org_name: "General"
    # get all users
    UserOrg.where(org_id: main_org.id).find_each do |user|
      # for each user, get all of their targets
      # I use a join here to get user data and target data. The user data can be used to create the message to the user - functionality to be added
      Target.select("users.*, targets.*").joins(:user).where(targets: {user_id: user.user_id}).find_each do |target|
        if target.address.blank? or target.city.blank?
          address = target.state
          @reps = civic_api(address).officials[2,2]
        else
          address = target.address + " " + target.city + " " + target.state
          @reps = civic_api(address).officials[2,3]


        end
        # send an email to each target
        TargetMailer.target_email(target.email,target.salutation,@message.title,@message.message_text,@reps).deliver_now


        # create a target message for each message sent to a target
        targmess = Targetmessage.new do |m|
          m.sent_date = Date.today
          m.message_text = @message.message_text
          m.user_id = target.user_id
          m.target_id = target.id
        end

        targmess.save
      end
    end
    # create 1 record that the message was sent. This is part of the message history
    mess = Messhistory.new do |m|
      m.sent_date = Date.today
      m.message_id = @message.id
      m.org_id = @message.org_id
    end
    mess.save
    redirect_to messages_path
  end

  def destroy
    @message = Message.find params[:message_id]
    message_sent = Messhistory.where(message_id: params[:message_id]).exists?
    if message_sent
        flash[:notice] = "Messages cannot be changed if they have been sent"
    else
      @message.destroy
        flash[:notice] = "Message deleted"
    end
    redirect_to messages_path

  end

  def civic_api(address)
    # construct the url
    url = "https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyBH9gjtOwvfkbDqxLoFdbfcR2tB978ETew&address=" + address
    # call the url using the net/http structure
    uri = URI(url)
    puts response = Net::HTTP.get(uri)
    # get a response and convert the hash (JSON) into an object
    res =  JSON.parse(response, object_class: OpenStruct)
  end

  private

  def message_params
    params.require(:message).permit(:title, :message_text, :create_date, :org_id)
  end

end
