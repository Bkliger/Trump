class ChangeEmailText < ActiveRecord::Migration
  change_table :targets do |t|

    t.column :contact_method, :integer
    t.remove :rec_email, :rec_text
  end
end
