class SiteController < ApplicationController
  def splash
    flash[:notice] = ""
    render :splash
  end
end
