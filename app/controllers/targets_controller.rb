class TargetsController < ApplicationController

  def index
    @user = current_user
    @targets = Target.where("user_id = ?",current_user)
  end

  def edit
    @target = Target.find(params[:target_id])
  render :edit
  end

  def new
    @target = Target.new
    render :new
  end

  def create
    @target = Target.create(target_params)
    redirect_to targets_path
  end

  def update
    @target = Target.find params[:target_id]
    @target.update(target_params)
    redirect_to targets_path
  end

  def destroy
    @target = Target.find params[:target_id]
    @target.destroy
    flash[:notice] = "Target deleted"
    redirect_to targets_path
  end

  private

  def target_params
    params.require(:target).permit(:first, :last, :zip, :plus4, :salutation, :email, :rec_email, :rec_text, :phone, :user_id)
  end


end
