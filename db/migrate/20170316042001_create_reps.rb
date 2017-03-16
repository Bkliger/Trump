class CreateReps < ActiveRecord::Migration
  def change
    create_table :reps do |t|
      t.string :first_name
      t.string :first_three
      t.string :last_name
      t.string :url

      t.timestamps null: false
    end
  end
end
