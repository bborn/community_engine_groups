class AddMembershipStatuses < ActiveRecord::Migration
  def self.up
    MembershipStatus.enumeration_model_updates_permitted = true    
    MembershipStatus.create :name => "pending"
    MembershipStatus.create :name => "accepted"
    MembershipStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    MembershipStatus.enumeration_model_updates_permitted = true    
    MembershipStatus.destroy_all
    MembershipStatus.enumeration_model_updates_permitted = false
  end
end
