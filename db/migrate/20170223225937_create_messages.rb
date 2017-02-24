class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :title
      t.text :message_text
      t.date :create_date
      t.references :org, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
