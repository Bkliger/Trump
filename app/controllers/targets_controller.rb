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
      @target = Target.friendly.find(params[:target_id])
      render :edit
    else
      redirect_to splash_path
    end
  end

  def step_two_edit
    if current_user
      @target = Target.friendly.find(params[:target_id])
      render :step_two
    else
      redirect_to splash_path
    end
  end

  def step_three_edit
    if current_user
      @target = Target.friendly.find(params[:target_id])
      render :step_three
    else
      redirect_to splash_path
    end
  end

  def step_three_update
    # test_twilio
    @target = Target.friendly.find(params[:target_id])
    @target.update(target_params)
    if @target.valid?
    else
      flash[:notice] = @target.errors.full_messages.to_sentence
      redirect_to edit_target_path(@target)
      return
    end
    #get most recent message
    message_history = Messhistory.last
    message = Message.find(message_history.message_id)
    #get target
    target = Target.friendly.find(params[:target_id])
    request_origin = "finish"
    create_single_message(current_user,target,message,request_origin)
    redirect_to targets_path
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
    if !target_params[:zip].blank?
        @sunlight_reps = sunlight_api(target_params[:zip])
        if @sunlight_reps.results == []
            flash[:notice] = 'Invalid Zip Code'
            @target = Target.new(target_params)
            render :new
            return
        end
    end
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

  def step_two_update
    if !target_params[:zip].blank?
        @sunlight_reps = sunlight_api(target_params[:zip])
        if @sunlight_reps.results == []
            flash[:notice] = 'Invalid Zip Code'
            if current_user
              @target = Target.friendly.find(params[:target_id])
              @more_info_needed = 1
              @skip_message = "yes"
              render :step_two
              return
            else
              redirect_to splash_path
            end
        end
    end
    # test_twilio
    @target = Target.friendly.find(params[:target_id])
    @target.update(target_params)
    if @target.valid?
    else
      flash[:notice] = @target.errors.full_messages.to_sentence
      redirect_to edit_target_path(@target)
      return
    end
    request_origin = "step_two"
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
    @target = Target.friendly.find(params[:target_id])
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
    @target = Target.friendly.find(params[:target_id])
    @target.update(status: "Unsubscribed")
    render :unsubscribe
  end

  def inactivate
    @target = Target.friendly.find(params[:target_id])
    @target.update(status: "Inactive")
    redirect_to targets_path
  end



  private


  def target_params
    params.require(:target).permit(:first_name, :last_name, :address, :city, :state, :zip, :salutation, :email, :contact_method, :phone, :user_id)
  end


end
