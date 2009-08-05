class RenameRoleIdToGroupRoleIdInGroupPermissions < ActiveRecord::Migration
  def self.up
    rename_column "group_permissions", "role_id", "group_role_id"
  end

  def self.down
    rename_column "group_permissions", "group_role_id", "role_id"
  end
end
