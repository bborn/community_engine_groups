class Group < ActiveRecord::Base
  acts_as_commentable
  attr_accessor :avatar_upload

  validates_presence_of :name

  has_many :group_memberships, :dependent => :destroy
  has_many :members, :through => :group_memberships, :source => :user
  has_many :active_members, :through => :group_memberships, :source => :user, :conditions => ["active = ?", true]
  has_many :owners,  :through => :group_memberships, :conditions => ['owner = ?', true], :source => :user
  
  has_many    :photos, :as => :attachable, :dependent => :destroy, :class_name => "GroupPhoto"
  belongs_to  :avatar, :class_name => "GroupPhoto"   
  validates_associated :avatar  
  after_save  :save_avatar  
  
  acts_as_activity :user
  
  #weird hacks because commentable_controller is pretty brittle and needs refactoring
  def user_id
    owner.id
  end
  def user
    owner
  end
  def owner
    owners.first
  end
  
  def add_owner(user)
    add_member(user, {:owner => true, :active => true})
  end
  
  def add_member(user, options = {:active => true})
    membership = GroupMembership.new({:group => self, :user => user}.merge(options))
    self.group_memberships << membership
  end
  
  def add_avatar(params)
    return if invalid_uploaded_data?(params)      
    self.avatar = self.photos.new
    self.avatar.uploaded_data = params
  end
  
  def save_avatar
    if valid? && self.avatar
      self.avatar.attachable = self
      self.avatar.save
    end
  end
  
  def invalid_uploaded_data?(uploaded_data)
    uploaded_data.nil? || (uploaded_data.is_a?(String) && uploaded_data.empty?)
  end
  
  def avatar_photo_url(size = nil)
    if avatar
      avatar.public_filename(size)
    else
      case size
        when :thumb
          AppConfig.photo['missing_thumb']
        else
          AppConfig.photo['missing_medium']
      end
    end
  end

  def membership_can_be_requested_by?(user)
    public? && !member?(user)
  end
  
  def member?(user)
    members.include?(user)    
  end
  
  def membership(user)
    GroupMembership.find_by_user_id_and_group_id(user.id, self.id)
  end
  
  def is_owned_by?(user)
    owners.include?(user)
  end
  
  def is_not_owned_by?(user)
    !is_owned_by?(user)
  end


end
