class RemoveSlugIndex < ActiveRecord::Migration
  def change
    remove_index :targets, :slug
  end
end
