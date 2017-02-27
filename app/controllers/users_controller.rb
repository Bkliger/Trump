class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:user_id])
  end
  render :edit
  end

  def new
    @user = User.new
    render :new
  end

  def create
    user_params = params.require(:user).permit(:first,:last)
    @user = User.create(user_params)
    redirect_to users_path
  end

  def update
    @user = User.find params[:user_id]
    @user.update(user_params)
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:first, :last)
  end


end
