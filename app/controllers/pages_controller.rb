class PagesController < ApplicationController
    def show
          flash[:notice] = ""
        render template: "pages/#{params[:page]}"
    end
end
