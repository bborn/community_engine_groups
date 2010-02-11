# Add CE Groups routes 
route "map.routes_from_plugin :community_engine_groups"
 
# Generate migrations
in_root do
  run_ruby_script "script/generate plugin_migration"
end

plugin 'resource_controller', :git => 'git://github.com/jamesgolick/resource_controller.git', :submodule => true
  
gem "formtastic", :source => 'http://gems.gemcutter.com'  
gem 'factory_girl', :source => 'http://gems.gemcutter.com'  
gem 'flexmock', :source => 'http://gems.gemcutter.com'  
gem 'mocha', :source => 'http://gems.gemcutter.com'  

# Migrate
rake('db:migrate')

# Success!
puts "SUCCESS!"
puts "Next, you should probably run `rake test` and `rake community_engine_groups:test` and make sure all tests pass. "
