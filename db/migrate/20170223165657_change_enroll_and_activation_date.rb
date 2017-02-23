class ChangeEnrollAndActivationDate < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :enrollment, :date
      t.change :inactivation, :date
    end
  end
end
