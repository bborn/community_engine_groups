class GroupMembershipsController < BaseController
  before_filter :find_group

  def create
    @user  = current_user
    @group.add_member(@user)
    
    flash[:notice] = :user_joined_group.l
    
    redirect_to @group
  end
  
  def destroy
    group_membership = @group.group_memberships.find(params[:id])
    group_membership.destroy
    
    if @group.is_owned_by?(current_user)
      flash[:notice] = :user_was_removed_by_group_owner.l
    else
      flash[:notice] = :user_left_group.l
    end
    
    redirect_to @group    
  end
  
  def index
    @group_memberships = @group.group_memberships
  end


  private
    def find_group
      @group = Group.find(params[:group_id])   
    end

end