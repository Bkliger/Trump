class AddAddressToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :address, :string
    add_column :targets, :city, :string
    add_column :targets, :state, :string
  end
end
