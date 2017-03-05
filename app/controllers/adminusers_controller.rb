class AdminusersController < ApplicationController

  def new_signin
    @adminuser = Adminuser.new
  end

  def signin
    @registered = Adminuser.first
    puts adminuser_params[:email]
    if adminuser_params[:email] == @registered.email
      redirect_to messages_path
    else
      flash[:notice] = "Incorrect Admin Email"
      redirect_to adminusers_path
    end

  end

  private

  def adminuser_params
    params.require(:adminuser).permit(:first_name, :last_name, :email)
  end
end
