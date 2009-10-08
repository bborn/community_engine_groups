class GroupMembershipsController < BaseController
  before_filter :find_group
  before_filter :group_membership_required, :only => [:index]
  before_filter :login_required,            :only => [:create, :destroy, :activate, :deactivate]
  before_filter :owner_or_admin_required,   :only => [:invite]  

  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_username]
  
  def auto_complete_for_username
    @users = User.find(:all, :conditions => [ 'LOWER(login) LIKE ?', '%' + (params[:user_names]) + '%' ])
    render :inline => "<%= auto_complete_result(@users, 'login') %>"
  end

  def create
    @user  = current_user
    @group.add_member(@user)
    
    flash[:notice] = :user_joined_group.l
    
    redirect_to @group
  end
  
  def destroy
    group_membership = @group.group_memberships.find(params[:id])
    
    group_membership.destroy if (group_membership.can_be_removed_by?(current_user))
    
    if owner_or_admin?
      flash[:notice] = :user_was_removed_by_group_owner.l
    else
      flash[:notice] = :user_left_group.l
    end
    
    redirect_to @group    
  end
  
  def index
    if owner_or_admin?
      @group_memberships = @group.group_memberships.find(:all, :page => {:current => params[:page], :size => 20})
    else
      @group_memberships = @group.group_memberships.active.find(:all, :page => {:current => params[:page], :size => 20})   
    end
  end

  def invite        
    if request.post?
      params[:user_names].split(',').uniq.each do |user_name|
        user = User.find_by_login(user_name.strip)
        @group.add_member(user, {:active => false})
      end
      redirect_to :action => :index
    end
  end

  def activate
    group_membership = @group.group_memberships.find(params[:id])
    group_membership.activate if group_membership.can_be_removed_by?(current_user)
    flash[:notice] = :the_user_was_activated.l

    redirect_to owner_or_admin? ? {:action => :index} : group_path(@group)
  end
  
  def deactivate
    group_membership = @group.group_memberships.find(params[:id])
    group_membership.deactivate if group_membership.can_be_removed_by?(current_user)

    redirect_to owner_or_admin? ? {:action => :index} : group_path(@group)
  end  


  private
  
    def owner_or_admin?
      @owner_or_admin = logged_in? && (current_user.admin? || @group.is_owned_by?(current_user))    
      @owner_or_admin
    end
  
    def owner_or_admin_required
      owner_or_admin? ? true : access_denied
    end
  
    def find_group
      @group = Group.find(params[:group_id])   
    end
    
    def group_membership_required
      if @group.public?
        true
      else
        logged_in? && (current_user.admin? || current_user.is_member_of?(@group)) ? true : access_denied      
      end
    end

end