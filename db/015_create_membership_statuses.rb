class CreateMembershipStatuses < ActiveRecord::Migration
  def self.up
    create_table :membership_statuses do |t|
      t.column :name, :string
    end
    add_column "memberships", "membership_status_id", :integer
  end

  def self.down
    drop_table :membership_statuses
    remove_column "memberships", "membership_status_id"
  end
end
