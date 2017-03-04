class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:user_id])
    render :edit
  end

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.create(user_params)
    redirect_to users_path
  end

  def update
    @user = User.find params[:user_id]
    @user.update(user_params)
    redirect_to users_path
  end

  def destroy
    @user = User.find params[:user_id]
    @user.destroy
    flash[:notice] = "You have successfully left Stop Trump and all of your Friends and Family have been removed."
    redirect_to splash_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end


end
