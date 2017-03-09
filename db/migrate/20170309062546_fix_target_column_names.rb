class FixTargetColumnNames < ActiveRecord::Migration
  def change
    change_table :targets do |t|
      t.rename :first, :first_name
      t.rename :last, :last_name
    end

  end
end
