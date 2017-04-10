class AddHotTextMessage < ActiveRecord::Migration
  def change
      add_column :orgs, :hot_text_message, :text
  end
end
