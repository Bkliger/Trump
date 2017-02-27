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
    main_org = Org.find_by org_name: "General"

    UserOrg.where(org_id: main_org.id).find_each do |user|
      targ = Target.select("users.*, targets.*").joins(:user).where(targets: {user_id: user.user_id}).find_each do |target|

        targmess = Targetmessage.new do |m|
          m.sent_date = Date.today
          m.message_text = @message.message_text
          m.user_id = target.user_id
          m.target_id = target.id
        end
      targmess.save
      end
    end
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
