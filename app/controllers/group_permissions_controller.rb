class GroupPermissionsController < BaseController
  # GET /group_permissions
  # GET /group_permissions.xml
  def index
    @group_permissions = GroupPermission.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group_permissions }
    end
  end

  # GET /group_permissions/1
  # GET /group_permissions/1.xml
  def show
    @group_permission = GroupPermission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group_permission }
    end
  end

  # GET /group_permissions/new
  # GET /group_permissions/new.xml
  def new
    @group_permission = GroupPermission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group_permission }
    end
  end

  # GET /group_permissions/1/edit
  def edit
    @group_permission = GroupPermission.find(params[:id])
  end

  # POST /group_permissions
  # POST /group_permissions.xml
  def create
    @group_permission = GroupPermission.new(params[:group_permission])

    respond_to do |format|
      if @group_permission.save
        flash[:notice] = 'GroupPermission was successfully created.'
        format.html { redirect_to(@group_permission) }
        format.xml  { render :xml => @group_permission, :status => :created, :location => @group_permission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /group_permissions/1
  # PUT /group_permissions/1.xml
  def update
    @group_permission = GroupPermission.find(params[:id])

    respond_to do |format|
      if @group_permission.update_attributes(params[:group_permission])
        flash[:notice] = 'GroupPermission was successfully updated.'
        format.html { redirect_to(@group_permission) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /group_permissions/1
  # DELETE /group_permissions/1.xml
  def destroy
    GroupPermission.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to(group_permissions_url) }
      format.xml  { head :ok }
    end
  end
end
