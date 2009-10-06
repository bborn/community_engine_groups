ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'
require 'action_view/test_case'
require 'pp'

ActiveSupport::TestCase.fixture_path = (RAILS_ROOT + "/vendor/plugins/community_engine/test/fixtures/")
ActionController::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

require 'flexmock/test_unit'
require 'mocha'


class ActiveSupport::TestCase
  include AuthenticatedTestHelper
     
end
