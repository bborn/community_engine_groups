class AddTypeToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :type, :string

    GroupRole.enumeration_model_updates_permitted = true
    GroupRole.create(:name => 'Owner')
    GroupRole.create(:name => 'Fan')
    Role.enumeration_model_updates_permitted = false
  end

  def self.down
    remove_column :roles, :type
  end
end
