class Target < ActiveRecord::Base
  before_create do
    self.status = "Incomplete"

  end

  belongs_to :user
  has_many :targetmessages, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  # validates :salutation, presence: true
  validates :state, presence: true
  # validates :email, presence: {message: "must be entered if you checked receive email"}, if: [:rec_email?]
  # validates :phone, presence: {message: "must be entered if you checked receive text"}, if: [:rec_text?]
  # validates :rec_email, presence: true, unless: :rec_text
  # validates :rec_text, presence: true, unless: :rec_email
  validates_format_of :email,:with => Devise::email_regexp, allow_blank: true
  # validates :zip, length: { is: 5 }

  enum contact_method: [ :email, :text]

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
