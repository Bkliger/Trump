class Org < ActiveRecord::Base
  has_many :user_orgs
  has_many :users, through: :user_orgs
end
