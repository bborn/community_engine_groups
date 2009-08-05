class AddInitiatorToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :initiator, :boolean, :default => false
  end

  def self.down
    remove_column :memberships, :initiator
  end
end
