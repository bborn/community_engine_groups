# Plugin routes go here
# app this to your app's routes file to make these routes active:


resources :groups do |group|
  group.resources :photos, :controller => "group_photos"
  group.resources :memberships, :controller => "group_memberships", :member => {:activate => :any, :deactivate => :put}, :collection => {:invite => :any, :auto_complete_for_username => :any}
end

user_group '/:user_id/groups/:id', :controller => 'groups', :action => 'show'
