class Target < ActiveRecord::Base
  belongs_to :user
  has_many :targetmessages, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :salutation, presence: true
  validates :email, presence: true
end
