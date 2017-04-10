class AddOrgColumn < ActiveRecord::Migration
  def change
      add_column :orgs, :hot_message, :text
  end
end
