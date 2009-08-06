resources :groups, :member => {
  :change_profile_groupphoto => :put,
  :welcome_groupphoto => :get,
  :roster => :get,
  } do |group|
  group.resources :groupphotos, :collection => {:swfupload => :post, :slideshow => :get}
  group.resources :memberships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
end

user_group ':user_id/groups/:id', :controller => 'groups', :action => "show"
#hmm, this is bogus

memberships '/memberships', :controller => 'memberships', :action => 'index'
resources :group_permissions