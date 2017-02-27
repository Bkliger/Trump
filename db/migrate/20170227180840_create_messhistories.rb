class CreateMesshistories < ActiveRecord::Migration
  def change
    create_table :messhistories do |t|
      t.date :sent_date
      t.references :message, index: true, foreign_key: true
      t.references :org, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
