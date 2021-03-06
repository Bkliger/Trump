class TargetsController < ApplicationController

    before_filter :authorize, only: [:index, :new, :edit, :update, :step_two_edit, :step_three_edit]

    def authorize
        if !current_user
            flash[:notice] = "You must log in/sign up to access Stop Trump"
            redirect_to splash_path
        end
    end

    def index
        main_org = Org.find_by org_name: 'General'
        # get most recent message
        message_history = Messhistory.last
        @sent_date = message_history.created_at.strftime("%m/%d/%Y")
        @general_message = Message.find(message_history.message_id)

        @hot_message = main_org.hot_message
        flash[:notice] = ""
        @user = current_user
        @targets = Target.where('user_id = ?', current_user).paginate(:page => params[:page], :per_page => 15).order(:status)
    end

    def new
        @target = Target.new
        render :new
    end

    def create
        unless target_params[:zip].blank?
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
        request_origin = 'create'
        lookup_reps(@target, request_origin)
    end

    def edit
        @target = Target.friendly.find(params[:target_id])
        render :edit
    end

    def update
        flash[:notice] = nil
        error_array = []
        @target = Target.friendly.find(params[:target_id])
        # if there were changes
        if (@target.address != target_params[:address]) || (@target.city != target_params[:city]) ||  (@target.state != target_params[:state]) || (@target.zip != target_params[:zip])
            request_origin = 'update_step_1'
            if !target_params[:zip].blank?
                @sunlight_reps = sunlight_api(target_params[:zip])
                if @sunlight_reps.results == []
                    error_array << 'Invalid Zip Code'
                end
            end
            if !target_params[:address].blank? || !target_params[:city].blank?
                usps_lookup(target_params[:address],target_params[:city],target_params[:state])
                if @bad_address == true
                    error_array << target_params[:address] + " " + target_params[:city] + " " + target_params[:state] + " " + 'is not a valid address. You can leave Address and City blank and we will search based on Zip or State.'
                end
            end
            flash[:notice] = error_array.to_sentence unless error_array.empty?
            unless flash[:notice].nil?
                if current_user
                    @target = Target.friendly.find(params[:target_id])
                    @more_info_needed = 1
                    @skip_message = 'yes'
                    render :edit
                    return
                else
                    redirect_to splash_path
                end
            end
        end
        @target.update(target_params)
        if @target.valid?
        else
          flash[:notice] = @target.errors.full_messages.to_sentence
          redirect_to edit_target_path(@target)
          return
        end
        request_origin = 'update_step_1'
        lookup_reps(@target, request_origin)
    end

    def step_two_edit
        @target = Target.friendly.find(params[:target_id])
        render :step_two
    end

    def step_two_update
        flash[:notice] = nil
        error_array = []
        @target = Target.friendly.find(params[:target_id])
        request_origin = 'update_step_2'
        # if the address has changed
        if (@target.address != target_params[:address]) || (@target.city != target_params[:city]) ||  (@target.state != target_params[:state]) || (@target.zip != target_params[:zip])
            request_origin = 'update_step_1'
            # if the zip has been entered, validate the zip. If invalid, inhibit have
            if !target_params[:zip].blank?
                @sunlight_reps = sunlight_api(target_params[:zip])
                if @sunlight_reps.results == []
                    error_array << 'Invalid Zip Code'
                end
            end
            # if entered address or city is not blank - validate the address. If invalid, don't let the record be saved
            if !target_params[:address].blank? || !target_params[:city].blank?
                usps_lookup(target_params[:address],target_params[:city],target_params[:state])
                if @bad_address == true
                    error_array << target_params[:address] + " " + target_params[:city] + " " + target_params[:state] + " " + 'is not a valid address.'
                end
            end
            flash[:notice] = error_array.to_sentence unless error_array.empty?
            unless flash[:notice].nil?
                if current_user
                    @target = Target.friendly.find(params[:target_id])
                    @more_info_needed = 1
                    @skip_message = 'yes'
                    render :step_two
                    return
                else
                    redirect_to splash_path
                end
            end
        end
        @target.update(target_params)
        if @target.valid?
            lookup_reps(@target, request_origin)
        end
    end

    def step_three_edit
        @target = Target.friendly.find(params[:target_id])
        render :step_three
    end

    def step_three_update #the finish button
        flash[:notice] = nil
        error_array = []
        if target_params[:salutation].blank?
            error_array << 'Greeting is required'
        end
        if target_params[:contact_method] == 'email_val' && target_params[:email].blank?
            error_array << 'If Email is checked, you must enter an Email Address'
        end
        if target_params[:contact_method] == 'text_val' && target_params[:phone].blank?
            error_array << 'If Text is checked, you must enter a phone number.'
        end
        flash[:notice] = error_array.join(', ') unless error_array.empty?
        unless flash[:notice].nil?
            if current_user
                @target = Target.friendly.find(params[:target_id])
                @status = @target.status
                render :step_three
                return
            else
                redirect_to splash_path
            end
        end
        @target = Target.friendly.find(params[:target_id])
        if target_params[:status] == "Incomplete"
            tp = target_params
            tp[:status] = "Active"
            @target.update(tp)
        else
            @target.update(target_params)
        end
        if @target.valid?
        else
          flash[:notice] = @target.errors.full_messages.to_sentence
          # redirect_to edit_target_path(@target)
          render :step_three
          return
        end
        # create dummy message for the call to create_single_message
        message = Message.new
        request_origin = 'finish'
        create_single_message(current_user, @target, message, request_origin)
        redirect_to targets_path
    end

    def destroy
        @target = Target.friendly.find(params[:target_id])
        @target.destroy
        flash[:notice] = 'Friends and Family Deleted'
        redirect_to targets_path
    end

    def unsubscribe
        @target = Target.friendly.find(params[:target_id])
        @target.update(status: 'Unsubscribed')
        render :unsubscribe
    end

    def inactivate
        @target = Target.friendly.find(params[:target_id])
        @target.update(status: 'Inactive')
        redirect_to targets_path
    end

    def report
        @user_count = User.count
        @statuses = Target.group(:status).count
        render :report
        # @status_active
        # @status_inactive
        # @status_incomplete
        # @status_no_republicans
    end

    def map
        @targets = Target.all
        res_array = []

        @targets.each do |t|
            if !t.address.blank? && !t.city.blank? && !t.state.blank?
              res = lat_long_lookup(t)
              res_array << res
            end
        end
        @hash = Gmaps4rails.build_markers(res_array) do |r, marker|
          marker.lat r.results[0].geometry.location.lat
          marker.lng r.results[0].geometry.location.lng
        end


# [{:lat=>40.590351, :lng=>40.590351}, {:lat=>42.3213849, :lng=>42.3213849}, {:lat=>29.72695119999999, :lng=>29.72695119999999}]
    end





    private

    def target_params
        params.require(:target).permit(:first_name, :last_name, :address, :city, :state, :zip, :salutation, :email, :contact_method, :phone, :user_id, :status)
    end
end
