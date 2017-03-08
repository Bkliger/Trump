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
    if @target.valid?
    else
      flash[:notice] = @target.errors.messages
      @target = Target.new(target_params)
      render :new
      return
    end
    lookup_reps

  end

  def update
    @target = Target.find params[:target_id]
    @target.update(target_params)
    if @target.valid?
    else
      flash[:notice] = @target.errors.messages
      redirect_to edit_target_path(@target)
      return
    end
    lookup_reps
  end

  def destroy
    @target = Target.find params[:target_id]
    @target.destroy
    flash[:notice] = "Target deleted"
    redirect_to targets_path
  end

  def lookup_reps
    case
    # zip is blank and state is blank
    when (target_params[:zip].blank? and target_params[:state].blank?)
      @target_message = "State is required"
      render "target_message"
    #zip is not blank
    when (!target_params[:zip].blank?)
      republican_count = 0
      representative_count = 0
      @sunlight_reps = sunlight_api(@target.zip)
      if @sunlight_reps.results == []

        @target_message = "Invalid Zip Code"
      else
        @sunlight_reps.results.each do |r|
          representative_count = representative_count + 1
          if r.party == "R"
                republican_count = republican_count + 1
          end
        end
        if republican_count == 0
            @target_message = "There are no Republican Senators or Representatives for this person."
        elsif representative_count > 3
          # if you have the full address
            if (!target_params[:address].blank? and !target_params[:city].blank? and !target_params[:state].blank?)
              address = @target.address + " " + @target.city + " " + @target.state
              republican_count = 0
              @civic_reps = civic_api(address).officials[2,2]
              @civic_reps.each do |r|
                if r.party == "Republican"
                  republican_count = republican_count + 1
                end
              end
              if republican_count > 0
                @target_message = "Congresspeople found."
              else
                @target_message = "There are no Republican Senators or Representatives for this person."
              end
            #if you only have the state
            elsif ((target_params[:address].blank? or target_params[:city].blank?) and !target_params[:state].blank?)
              address = @target.state
              @civic_reps = civic_api(address).officials[2,2]
              @civic_reps.each do |r|
                if r.party == "Republican"
                  republican_count = republican_count + 1
                end
              end
              if republican_count > 0
                @target_message = "More than 1 representative found. Click the back button and enter the full address"
              else
                @target_message = "There are no Republican Senators or Representatives for this person."
              end
            else
                @target_message = "More than 1 representative found. Click the back button and enter the full address"
            end

        else
            @target_message = "Congresspeople found"
        end
      end
      render "target_message"
    #no zip and only state
    when (target_params[:zip].blank? and (target_params[:address].blank? or target_params[:city].blank?) and !target_params[:state].blank?)
      address = @target.state
      republican_count = 0
      civic_response = civic_api(address)
      if !civic_response.error.nil?
        @target_message = "No Information for this address"
      else
        @civic_reps = civic_response.officials[2,2]
        @civic_reps.each do |r|
          if r.party == "Republican"
            republican_count = republican_count + 1
          end
        end
        if republican_count > 0
          @target_message = "Republican Senators found. If you know the address, we can check for representatives."
        else
          @target_message = "There are no Republican Senators. If you know the address, we can check for representatives."
        end
      end
      render "target_message"
    #no zip and full address
    when (target_params[:zip].blank? and !target_params[:address].blank? and !target_params[:city].blank? and !target_params[:state].blank?)
      address = @target.address + " " + @target.city + " " + @target.state
      republican_count = 0
      if !civic_api(address).error.nil?
        @target_message = "No Information for this address"
      else
        @civic_reps = civic_api(address).officials[2,2]
        @civic_reps.each do |r|
          if r.party == "Republican"
            republican_count = republican_count + 1
          end
        end
        if republican_count > 0
          @target_message = "Congresspeople found."
        else
          @target_message = "There are no Republican Senators or Representatives for this person."
        end
      end
      render "target_message"
    when (!target_params[:zip].blank? and target_params[:state].blank?)
      puts "zip is entered but state is blank"
    when (!target_params[:zip].blank? and !target_params[:state].blank?)
      puts "zip is entered and state is entered"
    end

  end



  private


  def target_params
    params.require(:target).permit(:first, :last, :address, :city, :state, :zip, :salutation, :email, :rec_email, :rec_text, :phone, :user_id)
  end


end
