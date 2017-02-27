class CreateTargetmessages < ActiveRecord::Migration
  def change
    create_table :targetmessages do |t|
      t.date :sent_date
      t.text :message_text
      t.references :user, index: true, foreign_key: true
      t.references :messhistory, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
