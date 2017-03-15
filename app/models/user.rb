class User < ActiveRecord::Base
  after_create :write_UserOrg_record

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :targets, dependent: :destroy
  has_many :user_orgs, dependent: :destroy



  validates :first_name, presence: true
  validates :last_name, presence: true

  protected
    def write_UserOrg_record
        main_org = Org.find_by org_name: "General"
        UserOrg.create(user_id: self.id, org_id: main_org.id)
    end
end
