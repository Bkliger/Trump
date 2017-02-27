class User < ActiveRecord::Base
  has_many :user_orgs
  has_many :orgs, through: :user_orgs
  has_many :targets, dependent: :destroy
end
