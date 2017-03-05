class CreateAdminusers < ActiveRecord::Migration
  def change
    create_table :adminusers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.references :org, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
