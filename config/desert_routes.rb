# Plugin routes go here
# app this to your app's routes file to make these routes active:


resources :groups do |group|
  group.resources :photos, :controller => "group_photos"
  group.resources :memberships, :controller => "group_memberships"
end

user_group '/:user_id/groups/:id', :controller => 'groups', :action => 'show'
