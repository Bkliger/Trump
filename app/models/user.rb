class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :targets, dependent: :destroy
  has_many :user_orgs, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
end
