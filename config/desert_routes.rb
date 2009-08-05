resources :groups, :member => {
  :change_profile_groupphoto => :put,
  :welcome_groupphoto => :get,
  :roster => :get,
  } do |group|
  group.resources :groupphotos, :collection => {:swfupload => :post, :slideshow => :get}
  group.resources :memberships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
end


resources :groups, :belongs_to => :user

memberships '/memberships', :controller => 'memberships', :action => 'index'
resources :group_permissions