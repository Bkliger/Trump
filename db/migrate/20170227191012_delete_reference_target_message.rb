class DeleteReferenceTargetMessage < ActiveRecord::Migration
  def change
    remove_reference(:targetmessages, :messhistory, index: true, foreign_key: true)
  end
end
