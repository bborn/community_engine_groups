class AddViewCountToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :view_count, :integer
  end

  def self.down
    remove_column :groups, :view_count
  end
end
