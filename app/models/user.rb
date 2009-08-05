class User < ActiveRecord::Base

  #group associations
  has_many :memberships
  has_many :groups, :through => :membership, :order => 'name'
  has_many :memberships_initiated_by_me, :class_name => "Membership", :foreign_key => "user_id", :conditions => ['initiator = ?', true], :dependent => :destroy

  def is_in_group?(group)
    groups.find_by_id(group.id)
  end

  def can_request_membership_with(group)
    !self.eql?(group.owner) && !self.membership_exists_with?(group)
  end

  def membership_exists_with?(group)
    Membership.find(:first, :conditions => ["group_id = ? AND user_id = ?", group.id, self.id])
  end

  def has_reached_daily_member_request_limit?
    memberships_initiated_by_me.count(:conditions => ['created_at > ?', Time.now.beginning_of_day]) >= Membership.daily_request_limit
  end
  
end