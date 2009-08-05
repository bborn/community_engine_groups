class Membership < ActiveRecord::Base
  @@daily_request_limit = 12
  cattr_accessor :daily_request_limit

  has_many :group_permissions, :dependent => :destroy
  
  validates_uniqueness_of :group_id, :scope => :user_id

  belongs_to :user
  belongs_to :group
  belongs_to :member, :class_name => "User", :foreign_key => "user_id"   
  has_enumerated :membership_status, :class_name => 'MembershipStatus', :foreign_key => 'membership_status_id'

  validates_presence_of   :membership_status
  validates_presence_of   :group
  validates_presence_of   :member
  validates_uniqueness_of :user_id, :scope => :group_id
 
  def is_group_owner?(group_role)
    self.group_permissions.find_by_group_role_id(group_role.id)
  end

  def is_in_group_role?(group_role)
    if self.group_permissions.find_by_group_role_id(group_role.id) != nil
      return true
    else
      return false
    end
  end
  
  # named scopes
  named_scope :accepted, lambda {
    #hack: prevents MembershipStatus[:accepted] from getting called before the membership_status records are in the db (only matters in testing ENV)
    {:conditions => ["membership_status_id = ?", MembershipStatus[:accepted].id]    }
  }
  validates_each :group_id do |record, attr, value|
    record.errors.add attr, 'can not be same as member' if record.group_id.eql?(record.user_id)
  end
  
  def validate  
    if new_record? && initiator && user.has_reached_daily_member_request_limit?
      errors.add_to_base("Sorry, you'll have to wait a little while before requesting any more memberships.")       
    end
  end  
    
  before_validation_on_create :set_pending

  attr_protected :membership_status_id
  
  def reverse
    Membership.find(:first, :conditions => ['group_id = ? and user_id = ?', self.user_id, self.group_id])
  end

  def denied?
    membership_status.eql?(MembershipStatus[:denied])
  end
  
  def pending?
    membership_status.eql?(MembershipStatus[:pending])
  end
  
  def self.members?(group, user)
    find(:first, :conditions => ["group_id = ? AND user_id = ? AND membership_status_id = ?", group.id, user.id, MembershipStatus[:accepted].id ])
  end
    
  private
  def set_pending
    membership_status_id = MembershipStatus[:pending].id
  end 
end
