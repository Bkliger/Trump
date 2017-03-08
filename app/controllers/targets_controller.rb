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

  # def finish
  #   puts "first name"
  #   puts params[:first]
  #   finish_parameters = {:target=> {first: params[:first],
  #     last: params[:last],
  #     address: params[:address],
  #     city: params[:city],
  #     state: params[:state],
  #     zip: params[:zip],
  #     salutation: params[:salutation],
  #     email: params[:email],
  #     rec_email: params[:rec_email],
  #     rec_text: params[:rec_text],
  #     phone: params[:phone],
  #     user_id: params[:user_id]
  #     }
  #   }

    # params = ActionController::Parameters.new(finish_parameters)

    # puts "these are the target"
    # puts Parameters

  # end


  def create
    @target = Target.create(target_params)
    # puts target_params
    if @target.valid?
      # redirect_to targets_path
    else
      flash[:notice] = @target.errors.messages
      # redirect_to "/targets/:" + @target.user_id.to_s + "/new"
      redirect_to new_target_path(current_user)
    end

    @target_params = target_params
    case
    when (!target_params[:zip].blank? and target_params[:state].blank?)
      @target_message = "State is the minimum required"
      render "target_message"
    when (target_params[:zip].blank? and target_params[:state].blank?)
      puts "State is the minimum required"
    when (target_params[:zip].blank? and (target_params[:address].blank? or target_params[:city].blank?) and !target_params[:state].blank?)
      puts "in right path"
      @target_message = "zip is blank and address or city is blank and state is entered"
      render "target_message"
    when (target_params[:zip].blank? and !target_params[:address].blank? and !target_params[:city].blank? and !target_params[:state].blank?)
      puts "zip is blank and address is entered"
    when (!target_params[:zip].blank? and target_params[:state].blank?)
      puts "zip is entered but state is blank"
    when (!target_params[:zip].blank? and !target_params[:state].blank?)
      puts "zip is entered and state is entered"

    end


    # @target = Target.create(target_params)
    # puts target_params
    # if @target.valid?
    #   redirect_to targets_path
    # else
    #   flash[:notice] = @target.errors.messages
    #   # redirect_to "/targets/:" + @target.user_id.to_s + "/new"
    #   redirect_to new_target_path(current_user)
    # end
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
    params.require(:target).permit(:first, :last, :address, :city, :state, :zip, :salutation, :email, :rec_email, :rec_text, :phone, :user_id)
  end


end
