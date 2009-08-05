# Add CE Groups routes 
route "map.routes_from_plugin :community_engine_groups"
 
# Generate migrations
in_root do
  run_ruby_script "script/generate plugin_migration"
end

# Migrate
rake('db:migrate')

# Success!
puts "SUCCESS!"
puts "Next, you should probably run `rake test` and `rake community_engine_groups:test` and make sure all tests pass. "
