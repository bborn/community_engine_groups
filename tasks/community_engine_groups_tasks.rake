require 'rake/clean'


namespace :community_engine_groups do   

  desc 'Test the community_engine plugin.'
  Rake::TestTask.new(:test) do |t|         
    t.libs << 'lib'
    t.pattern = 'vendor/plugins/community_engine/test/**/*_test.rb'
    t.verbose = true    
  end
  Rake::Task['community_engine:test'].comment = "Run the community_engine plugin tests."
  
end