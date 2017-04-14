class SiteController < ApplicationController
  def splash
    if current_user
        redirect_to targets_path
    else
        render :splash
    end
  end
end
