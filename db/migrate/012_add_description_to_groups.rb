class AddDescriptionToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :description, :string
  end

  def self.down
    remove_column :groups, :description
  end
end
