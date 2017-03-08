class Target < ActiveRecord::Base
  belongs_to :user
  has_many :targetmessages, dependent: :destroy

  validates :first, presence: true
  validates :last, presence: true
  validates :salutation, presence: true
  validates :email, presence: true
end
