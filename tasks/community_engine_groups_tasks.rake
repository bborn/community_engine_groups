require 'rake/clean'


namespace :community_engine_groups do   

  desc 'Test the community_engine_groups plugin.'
  Rake::TestTask.new(:test) do |t|         
    t.libs << 'lib'
    t.pattern = 'vendor/plugins/community_engine_groups/test/**/*_test.rb'
    t.verbose = true    
  end
  Rake::Task['community_engine_groups:test'].comment = "Run the community_engine_groups plugin tests."
  
end