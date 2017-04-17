class SiteController < ApplicationController
  def splash
    if current_user
        redirect_to targets_path
    else
        main_org = Org.find_by org_name: 'General'
        @hot_message = main_org.hot_message
        render :splash
    end
  end
end
