class RepsController < ApplicationController
    def index
        if current_user
          @reps = Rep.all
        else
          redirect_to splash_path
        end
    end

    def edit
        if current_user
          @rep = Rep.find(params[:rep_id])
          render :edit
        else
          redirect_to splash_path
        end
    end

    def update

      @rep = Rep.find params[:rep_id]
      @rep.update(rep_params)
      redirect_to reps_path
    end

    def destroy
      @rep = Rep.find params[:rep_id]
      @rep.destroy
      flash[:notice] = "Representative deleted"
      redirect_to reps_path
    end

    private


    def rep_params
      params.require(:rep).permit(:first_name, :first_three, :last_name, :url)
    end


end
