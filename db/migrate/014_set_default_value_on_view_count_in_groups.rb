class SetDefaultValueOnViewCountInGroups < ActiveRecord::Migration
  def self.up
    change_column :groups, :view_count, :integer, :default => 0
  end

  def self.down
  end
end
