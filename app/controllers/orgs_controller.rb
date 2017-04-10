class OrgsController < ApplicationController

  def index
      if current_user
          @orgs = Org.all

      else
          redirect_to splash_path
      end
  end

  def edit
      if current_user
          @org = Org.find(params[:org_id])
          render :edit
      else
          redirect_to splash_path
      end
  end

  def update
      @org = Org.find params[:org_id]
      @org.update(org_params)
      redirect_to orgs_path
  end

  private

  def org_params
      params.require(:org).permit(:org_name, :org_status, :hot_message, :hot_text_message)
  end
end
