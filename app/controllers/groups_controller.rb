class GroupsController < BaseController
  include Viewable
  cache_sweeper :taggable_sweeper, :only => [:activate, :update, :destroy]  
  
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit, :show])

  before_filter :admin_required, :except => [:index, :show]

  
  def index
    cond, @search, @metro_areas, @states = Group.paginated_groups_conditions_with_search(params)

    @groups = Group.find(:all,
      :conditions => cond.to_sql, 
      :include => [:tags], 
      :page => {:current => params[:page], :size => 20}
    )

    setup_metro_areas_for_cloud
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  def show
    @group = Group.find(params[:id])
    @groupphoto_comments = Comment.find_groupphoto_comments_for(@group)  
    @groupphotos = @group.groupphotos.find(:all, :limit => 5)
    
    @comments       = @group.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    @groups_comments = Comment.find_group_comments_for(@group)
    
    if @group.owner == current_user
      @is_group_owner = true
    else
      @is_group_owner = false
    end

    @member_count               = @group.accepted_memberships.count
    @accepted_memberships       = @group.accepted_memberships.find(:all, :limit => 5).collect{|f| f.member }
    @pending_memberships_count  = @group.pending_memberships.count()

    update_view_count(@group) unless @group.owner && current_user.eql?(@group)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    @membership = Membership.new
    @group_permission = GroupPermission.new
    @metro_areas = MetroArea.find(:all)
    @states = State.find(:all)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @metro_areas, @states = setup_locations_for(@group)
    @avatar = Groupphoto.new
    @groupphoto_comments = Comment.find_groupphoto_comments_for(@group)  
    @groupphotos = @group.groupphotos.find(:all, :limit => 5)
    if @group.owner == current_user
      @is_group_owner = true
    else
      @is_group_owner = false
    end
    

  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    #here we add the current user to the membership collection of the group
    @membership = @group.memberships.build(params[:membership])
    @membership.group = @group
    @membership.user = current_user
    @membership.initiator = false
    @membership.membership_status_id = 2
    
    #and here we set the current_user as the owner of the group
    @group_permission = @group.group_permissions.build(params[:group_permission])
    @group_permission.membership = @membership
    @group_permission.group_role = GroupRole.find_by_name('Owner')
    
    @group.metro_area  = MetroArea.find(params[:metro_area_id])
    @group.state       = (@group.metro_area && @group.metro_area.state) ? @group.metro_area.state : nil
    @group.country     = @group.metro_area.country if (@group.metro_area && @group.metro_area.country)

    
    #current_user.track_activity(:created_a_group)
    
#    unless @user.is_in_group?(@group)
#      @user.memberships << @group
#    end

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
   
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    unless params[:metro_area_id].blank?
      @group.metro_area  = MetroArea.find(params[:metro_area_id])
      @group.state       = (@group.metro_area && @group.metro_area.state) ? @group.metro_area.state : nil
      @group.country     = @group.metro_area.country if (@group.metro_area && @group.metro_area.country)
    else
      @group.metro_area = @group.state = @group.country = nil
    end

    @avatar = Groupphoto.new(params[:avatar])
    @avatar.group  = @group

    @group.avatar  = @avatar if @avatar.save

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    Group.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
  
  def metro_area_update
    return unless request.xhr?
    
    country = Country.find(params[:country_id]) unless params[:country_id].blank?
    state   = State.find(params[:state_id]) unless params[:state_id].blank?
    states  = country ? country.states.sort_by{|s| s.name} : []
    
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end

    render :partial => 'shared/group_location_chooser', :locals => {
      :states => states, 
      :metro_areas => metro_areas, 
      :selected_country => params[:country_id].to_i, 
      :selected_state => params[:state_id].to_i, 
      :selected_metro_area => nil }
  end

  def change_profile_photo
    @group   = Group.find(params[:id])
    @groupphoto  = Grouphoto.find(params[:groupphoto_id])
    @group.avatar = @groupphoto

    if @group.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to group_groupphoto_path(@group, @groupphoto)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def welcome_groupphoto
    @group = Group.find(params[:id])
  end

  def roster
    @group   = Group.find(params[:id])
  end
  
  protected  
    def setup_metro_areas_for_cloud
      @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "groups_count > 0", :order => "groups_count DESC", :limit => 100)
      @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
    end  
  
    def setup_locations_for(group)
      metro_areas = states = []
          
      states = group.country.states if group.country
      
      metro_areas = group.state.metro_areas.all(:order => "name") if group.state
    
      return metro_areas, states
    end


end
