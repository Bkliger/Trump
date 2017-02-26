class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :first
      t.string :last
      t.integer :zip
      t.integer :plus4
      t.string :salutation
      t.string :email
      t.boolean :rec_email
      t.boolean :rec_text
      t.string :phone
      t.boolean :unsubscribed
      t.date :unsubscribed_date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
