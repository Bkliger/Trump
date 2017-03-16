class AddIndexToRep < ActiveRecord::Migration
  def change
      add_index(:reps,[:first_three, :last_name],name: "unique_rep_index",unique: true)
  end
end
