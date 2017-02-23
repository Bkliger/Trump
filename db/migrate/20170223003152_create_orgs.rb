class CreateOrgs < ActiveRecord::Migration
  def change
    create_table :orgs do |t|
      t.string :org_name
      t.string :org_status

      t.timestamps null: false
    end
  end
end
