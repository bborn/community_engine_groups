class Group < ActiveRecord::Base
  acts_as_taggable  
  acts_as_commentable
  
  validates_presence_of     :name
  validates_presence_of     :metro_area, :if => Proc.new { |group| group.state }

  validates_format_of       :name, :with => /^[\sA-Za-z0-9_-]+$/

  belongs_to :metro_area
  belongs_to :state
  belongs_to :country
  belongs_to :avatar, :class_name => "Groupphoto", :foreign_key => "avatar_id"

  has_many :accepted_memberships, :class_name => "Membership", :conditions => ['membership_status_id = ?', 2]
  has_many :pending_memberships, :class_name => "Membership", :conditions => ['initiator = ? AND membership_status_id = ?', true, 1]
  has_many :memberships_initiated_by_me, :class_name => "Membership", :foreign_key => "group_id", :conditions => ['initiator = ?', false], :dependent => :destroy
  has_many :memberships_not_initiated_by_me, :class_name => "Membership", :foreign_key => "group_id", :conditions => ['initiator = ?', true], :dependent => :destroy
  has_many :occurances_as_member, :class_name => "Membership", :foreign_key => "member_id", :dependent => :destroy

  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :membership
  has_many :groupphotos, :order => "created_at desc", :dependent => :destroy
  has_many :group_permissions
  
  after_save    :recount_metro_area_groups
  after_destroy :recount_metro_area_groups

  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["tags.name = ?", tag_name], :include => :tags}
  }
  
  def owner # returns the user object
    @group_role = GroupRole.find_by_name("Owner")
    
    memberships.each do |member|
      if member.is_group_owner?(@group_role) 
        return User.find_by_id(member.user_id)
      end
    end
  end
  
  def members_in_role(role_names, in_role = true) #returns membership
    results = Array.new

    if role_names != nil
      role_names.each do |role_name|
        if role_name != nil
          @group_role = GroupRole.find_by_name(role_name)

          memberships.each do |member|
            results << member if member.is_in_group_role?(@group_role) == in_role && member.membership_status_id == 2
          end
        end
      end
    else
        memberships.each do |member|
          results << member
        end
    end
    
    return results
  end

  def recount_metro_area_groups
    return unless self.metro_area
    ma = self.metro_area
    ma.groups_count = Group.count(:conditions => ["metro_area_id = ?", ma.id])
    ma.save
  end  

  def location
    metro_area && metro_area.name || ""
  end
  
  def full_location
    "#{metro_area.name if self.metro_area}#{" , #{self.country.name}" if self.country}"
  end
  
  def self.find_country_and_state_from_search_params(search)
    country     = Country.find(search['country_id']) if !search['country_id'].blank?
    state       = State.find(search['state_id']) if !search['state_id'].blank?
    metro_area  = MetroArea.find(search['metro_area_id']) if !search['metro_area_id'].blank?

    if metro_area && metro_area.country
      country ||= metro_area.country 
      state   ||= metro_area.state
      search['country_id'] = metro_area.country.id if metro_area.country
      search['state_id'] = metro_area.state.id if metro_area.state      
    end
    
    states  = country ? country.states.sort_by{|s| s.name} : []
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end    
    
    return [metro_areas, states]
  end
  
  def self.prepare_params_for_search(params)
    search = {}.merge(params)
    search['metro_area_id'] = params[:metro_area_id] || nil
    search['state_id'] = params[:state_id] || nil
    search['country_id'] = params[:country_id] || nil
    search['skill_id'] = params[:skill_id] || nil    

    search
  end
  
  def self.build_conditions_for_search(search)
    cond = Caboose::EZ::Condition.new

    #cond.append ['activated_at IS NOT NULL ']
    if search['country_id'] && !(search['metro_area_id'] || search['state_id'])
      cond.append ['country_id = ?', search['country_id'].to_s]
    end
    if search['state_id'] && !search['metro_area_id']
      cond.append ['state_id = ?', search['state_id'].to_s]
    end
    if search['metro_area_id']
      cond.append ['metro_area_id = ?', search['metro_area_id'].to_s]
    end
    if search['name']    
      cond.append ["`groups`.`name` LIKE ?", '%' + search['name'].to_s + '%']
    end
    if search['description']
      cond.description =~ "%#{search['description']}%"
    end    
    cond
  end  
  
  def self.paginated_groups_conditions_with_search(params)
    search = prepare_params_for_search(params)

    metro_areas, states = find_country_and_state_from_search_params(search)
    
    cond = build_conditions_for_search(search)
    return cond, search, metro_areas, states
  end  

  #Groupphoto methods
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

  
end
