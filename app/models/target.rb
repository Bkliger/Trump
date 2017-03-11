class Target < ActiveRecord::Base
  before_create do
    self.status = "Incomplete"

  end

  belongs_to :user
  has_many :targetmessages, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :salutation, presence: true
  validates :email, presence: true, if: "!rec_email.blank?"
  validates :phone, presence: true, if: "!rec_text.blank?"
end
