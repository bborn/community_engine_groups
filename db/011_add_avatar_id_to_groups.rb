class AddAvatarIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :avatar_id, :integer
  end

  def self.down
    remove_column :groups, :avatar_id
  end
end
