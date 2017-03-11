class AddStatusToTarget < ActiveRecord::Migration
  def change
      add_column :targets, :status, :string
  end
end
