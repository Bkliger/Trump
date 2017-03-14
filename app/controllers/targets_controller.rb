class TargetsController < ApplicationController

  def index
    if current_user
      @user = current_user
      @targets = Target.where("user_id = ?",current_user)
    else
      redirect_to splash_path
    end
  end

  def edit
    if current_user
      # @target = Target.find(params[:target_id])
      @target = Target.friendly.find(params[:target_id])
      render :edit
    else
      redirect_to splash_path
    end
  end

  def new
    if current_user
      @target = Target.new
      render :new
    else
      redirect_to splash_path
    end
  end

  def create
    @target = Target.create(target_params)
    if @target.valid?
    else
      flash[:notice] = @target.errors.full_messages.to_sentence
      @target = Target.new(target_params)
      render :new
      return
    end
    request_origin = "create"
    lookup_reps(@target,request_origin)

  end

  def update
    # test_twilio
    @target = Target.friendly.find(params[:target_id])
    @target.update(target_params)
    if @target.valid?
    else
      flash[:notice] = @target.errors.full_messages.to_sentence
      redirect_to edit_target_path(@target)
      return
    end
    request_origin = "update"
    lookup_reps(@target,request_origin)
  end

  def destroy
    @target = Target.find params[:target_id]
    @target.destroy
    flash[:notice] = "Friends and Family Deleted"
    redirect_to targets_path
  end

  def finish
    #get most recent message
    message_history = Messhistory.last
    message = Message.find(message_history.message_id)
    #get target
    target = Target.friendly.find(params[:target_id])
    request_origin = "finish"


    create_single_message(current_user,target,message,request_origin)
    redirect_to targets_path
  end

  def unsubscribe
    @target = Target.find (params[:target_id])
    @target.update(status: "Unsubscribed")
    render :unsubscribe
  end

  def inactivate
    @target = Target.find (params[:target_id])
    @target.update(status: "Inactive")
    redirect_to targets_path
  end



  private


  def target_params
    params.require(:target).permit(:first_name, :last_name, :address, :city, :state, :zip, :salutation, :email, :rec_email, :rec_text, :phone, :user_id)
  end


end
