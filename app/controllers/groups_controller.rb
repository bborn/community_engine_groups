class GroupsController < BaseController
  resource_controller
  before_filter :login_required, :except => [:index, :show]
  before_filter :owner_or_admin_required, :only => [:edit, :update, :destroy]
  before_filter :group_membership_required, :only => [:show]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update, :show])  

  update.before do
    @object.add_avatar(object_params[:avatar_upload]) if object_params    
  end
    
  show.before do
    @comments = @group.comments.find(:all, :page => {:size => 10, :current => params[:page]})
  end  
    
  private
  
    def collection
      @collection ||= end_of_association_chain.find(:all, :page => {:size => 10, :current => params[:page]})
    end
  
    def build_object
      @object ||= current_user.groups.build object_params
      @object.add_owner(current_user)
      @object.add_avatar(object_params[:avatar_upload]) if object_params
      @object
    end
    
    def owner_or_admin_required
      logged_in? && (current_user.admin? || object.is_owned_by?(current_user)) ? true : access_denied
    end    
    
    def group_membership_required
      load_object
      if @group.public?
        true
      else
        logged_in? && (current_user.admin? || current_user.is_member_of?(@group)) ? true : access_denied      
      end
    end
    
  
end
