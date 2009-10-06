require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  
  fixtures :all
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should create group with current user as owner" do
    login_as :quentin
    
    assert_difference Group, :count do
      post :create, :group => {:name => 'Foo Group'}
    end
    
    assert assigns(:group).is_owned_by?(users(:quentin))
    
  end
  
end
