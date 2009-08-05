class AddGroupsCountToMetroArea < ActiveRecord::Migration
  def self.up
    add_column :metro_areas, :groups_count, :integer, :default => 0
  end

  def self.down
    remove_column :metro_areas, :groups_count
  end
end
