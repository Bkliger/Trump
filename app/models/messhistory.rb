class Messhistory < ActiveRecord::Base
  belongs_to :message
  belongs_to :org
end
