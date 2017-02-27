class Targetmessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :messhistory
end
