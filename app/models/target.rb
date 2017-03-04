class Target < ActiveRecord::Base
  belongs_to :user
  has_many :targetmessages, dependent: :destroy
end
