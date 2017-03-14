class FriendlyIdSlug < ActiveRecord::Migration
  def change
      add_column :targets, :slug, :string
      add_index :targets, :slug, unique: true
  end
end
