class SiteController < ApplicationController
  def splash
    if current_user
        redirect_to targets_path
    else
        flash[:notice] = ""
        render :splash
    end
  end
end
