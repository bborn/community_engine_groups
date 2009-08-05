class CreateGroupPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_permissions do |t|
      t.integer :membership_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :group_permissions
  end
end
