class MembershipsController < BaseController
  before_filter :login_required, :except => [:accepted, :index]
  before_filter :find_group, :only => [:accepted, :pending, :denied]
  before_filter :require_current_group_owner?, :only => [:accept, :deny, :pending, :destroy]

  def index
    @body_class = 'memberships-browser'
    
    @group = (params[:id] ||params[:group_id]) ? Group.find((params[:id] || params[:group_id] )): Membership.find(:first, :order => "rand()").group
    @memberships = Membership.find(:all, :conditions => ['group_id = ? OR user_id = ?', @group.id, current_user.id], :limit => 40, :order => "rand()")
    @groups = Group.find(:all, :conditions => ['groups.id in (?)', @memberships.collect{|f| f.user_id }])
    
    respond_to do |format|
      format.html 
      format.xml { render :action => 'index.rxml', :layout => false}    
    end
  end
  
  def deny
    @group = Group.find(params[:group_id])    
    @membership = @group.memberships.find(params[:id])
 
    respond_to do |format|
      if @membership.update_attributes(:membership_status => MembershipStatus[:denied]) && @membership.reverse.update_attributes(:membership_status => MembershipStatus[:denied])
        flash[:notice] = :the_membership_was_denied.l
        format.html { redirect_to denied_group_memberships_path(@group) }
      else
        format.html { render :action => "edit" }
      end
    end    
  end

  def accept
    @group = Group.find(params[:group_id])    
    @membership = @group.memberships_not_initiated_by_me.find(params[:id])
 
    respond_to do |format|
      # && @membership.reverse.update_attributes(:membership_status => MembershipStatus[:accepted])
      if @membership.update_attributes(:membership_status => MembershipStatus[:accepted]) 
        flash[:notice] = :the_membership_was_accepted.l
        format.html { 
          redirect_to accepted_group_memberships_path(@group) 
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def denied
    @group = Group.find(params[:group_id])    
    @memberships = @group.memberships.find(:all, :conditions => ["membership_status_id = ?", MembershipStatus[:denied].id], :page => {:current => params[:page]})
    
    respond_to do |format|
      format.html
    end
  end


  def accepted
    @group = Group.find(params[:group_id])    
    @member_count = @group.accepted_memberships.count
    @pending_memberships_count = @group.pending_memberships.count
          
    @memberships = @group.memberships.accepted.find :all, :page => {:size => 12, :current => params[:page], :count => @member_count}
    
    respond_to do |format|
      format.html
    end
  end
  
  def pending
    @group = Group.find(params[:group_id])

    if @group.owner == current_user
      @is_group_owner = true
    else
      @is_group_owner = false
    end

    @memberships = @group.memberships.find(:all, :conditions => ["initiator = ? AND membership_status_id = ?", true, MembershipStatus[:pending].id])
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @membership = Membership.find(params[:id])
    @group = @membership.group
    
    respond_to do |format|
      format.html
    end
  end
  

  def create
    @group = Group.find(params[:group_id])
    @membership = Membership.new(:group_id => params[:group_id], :user_id => params[:user_id], :initiator => true )
    @membership.membership_status_id = MembershipStatus[:pending].id    
    reverse_membership = Membership.new(params[:membership])
    reverse_membership.membership_status_id = MembershipStatus[:pending].id 
    reverse_membership.group_id, reverse_membership.user_id = @membership.user_id, @membership.group_id

    @group_permission = @group.group_permissions.build(params[:group_permission])
    @group_permission.group_role = GroupRole.find_by_name('Fan')

    respond_to do |format|
      if @membership.save #&& reverse_membership.save
        #TODO: allow the user to set a value to get these notifications or not. - if @membership.user.notify_member_requests?
        @group_permission.membership = @membership
        @group_permission.save

        UserNotifier.deliver_membership_request(@membership) 
        format.html {
          flash[:notice] = :membership_requested.l_with_args(:group => @membership.group.name)
          redirect_to accepted_group_memberships_path(@group)
        }
        format.js { render( :inline => :requested_membership_with.l+" #{@membership.group.name}." ) }
      else
        flash.now[:error] = :membership_could_not_be_created.l
        @groups = Group.find(:all)
        format.html { redirect_to group_memberships_path(@group) }
        format.js { render( :inline => "Membership request failed." ) }                
      end
    end
  end
    
  def destroy
    @group = Group.find(params[:group_id])    
    @membership = Membership.find(params[:id])
    Membership.transaction do 
      @membership.destroy
      @membership.reverse.destroy
    end
    respond_to do |format|
      format.html { redirect_to accepted_group_memberships_path(@group) }
    end
  end

  def require_current_group_owner?
    if current_user == current_group.owner
      return true
    else
      access_denied
    end
  end
  
end
