class TextMessage < ActiveRecord::Migration
  def change
      add_column :messages, :text_message, :text
  end
end
