class Target < ActiveRecord::Base
  before_create do
    self.status = "Incomplete"
    self.contact_method = "email_val"

  end

  belongs_to :user
  has_many :targetmessages, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :state, presence: true
  validates_format_of :email,:with => Devise::email_regexp, allow_blank: true

  enum contact_method: [ :email_val, :text_val]

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged


  def slug_candidates
  [
    [:first_name, :last_name],
    [:first_name, :last_name, :user_id]
  ]
  end

end

Target.find_each(&:save)
