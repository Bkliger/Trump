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

  private

  def message_params
    params.require(:message).permit(:title, :message_text, :create_date)
  end

end
