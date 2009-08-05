class AddStateIdCountryIdMetroAreaIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :state_id, :integer
    add_column :groups, :country_id, :integer
    add_column :groups, :metro_area_id, :integer
  end

  def self.down
    remove_column :groups, :state_id
    remove_column :groups, :country_id
    remove_column :groups, :metro_area_id
  end
end
