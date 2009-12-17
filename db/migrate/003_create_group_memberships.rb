class CreateGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table :group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :active, :default => false
      t.boolean :owner,  :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :group_memberships
  end
end
