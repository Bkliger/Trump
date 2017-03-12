class ChangeZip < ActiveRecord::Migration
  def change
    change_table :targets do |t|
      t.change :zip, :string
      t.change :plus4, :string
    end
  end
end
