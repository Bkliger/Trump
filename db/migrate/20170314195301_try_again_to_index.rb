class TryAgainToIndex < ActiveRecord::Migration
    def change
      add_index :targets, :slug, :unique => true
    end
end
