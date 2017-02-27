class AddTargetToTargetmessage < ActiveRecord::Migration
  def change
    add_reference :targetmessages, :target, index: true
  end
end
