class MessagesController < ApplicationController
  def index
    @messages = Message.all.order("create_date DESC")
  end

  def edit
    @message = Message.find(params[:message_id])
  render :edit
  end

  def new
    @message = Message.new
    render :new
  end

  def create
    @message = Message.create(message_params)
    redirect_to messages_path
  end

  def update
    @message = Message.find params[:message_id]
    @message.update(message_params)
    redirect_to messages_path
  end

  def send_message
    @message = Message.find params[:message_id]
    # this is a solution for a single org. this can be expanded when other organizations can create messages
    main_org = Org.find_by org_name: "General"
    # get all users
    UserOrg.where(org_id: main_org.id).find_each do |user|
      # for each user, get all of their targets
      # I use a join here to get user data and target data. The user data can be used to create the message to the user - functionality to be added
      targ = Target.select("users.*, targets.*").joins(:user).where(targets: {user_id: user.user_id}).find_each do |target|
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

  private

  def message_params
    params.require(:message).permit(:title, :message_text, :create_date)
  end

end
