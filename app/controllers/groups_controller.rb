class GroupsController < BaseController
  resource_controller
  before_filter :login_required, :except => [:index, :show]  
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
  
end
