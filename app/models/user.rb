class User < ActiveRecord::Base
  has_many :group_memberships, :dependent => :destroy
  has_many :groups, :through => :group_memberships
  
  has_many :groups_as_owner, :through => :group_memberships, :source => :group, :conditions => ["owner = ?", true], :dependent => :destroy

  def can_request_group_membership?(group)
    group.membership_can_be_requested_by?(self)
  end
  
  def is_member_of?(group)
    group.member?(self)
  end
  
end
