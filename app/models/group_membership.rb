class GroupMembership < ActiveRecord::Base
  
  validates_presence_of :user, :group
  validates_uniqueness_of :user_id, :scope => :group_id #can't be a member in the same group twice
  
  belongs_to :user
  belongs_to :group
  
  def can_be_removed_by?(a_user)
    group.is_not_owned_by?(user) && (group.is_owned_by?(a_user) || user.eql?(a_user))
  end
  
end