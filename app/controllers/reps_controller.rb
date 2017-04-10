class RepsController < ApplicationController
    def index
        if current_user
            @reps = Rep.paginate(page: params[:page], per_page: 50)

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
        flash[:notice] = 'Representative deleted'
        redirect_to reps_path
    end

    def lookup_all_reps #abandoned
        require 'csv'
        # library that handles http requests
        # used to create an object from a hash

        # read input csv file
        CSV.foreach('./us_postal_codes.csv') do |row|

            sunlight_reps = sunlight_api(row[0])
            sunlight_reps.results.each do |rep|
                CSV.open('rep_output2.csv', 'a+') do |csv|
                    csv << [rep.first_name, rep.last_name]
                end
            end
        end

        redirect_to targets_path
    end

    def check_congress  #abandoned
        require 'csv'
        # library that handles http requests

        # read input csv file
        CSV.foreach('./congress_check.csv') do |row|
            first_three = row[0].slice(0, 3)
            last_name = row[1]

            rep = Rep.where(first_three: first_three, last_name: last_name)
            next unless rep.blank?
            CSV.open('output2.csv', 'a+') do |csv|
                csv << [row[0], row[1]]
            end
        end
        redirect_to targets_path
    end

    private

    def rep_params
        params.require(:rep).permit(:first_name, :first_three, :last_name, :url)
    end
end
