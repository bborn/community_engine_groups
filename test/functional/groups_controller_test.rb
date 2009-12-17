require File.dirname(__FILE__) + '/../test_helper'

Factory.define :group do |g|
  g.name 'A group'
end    


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
  
  test "should not show private group to non member" do
    group = Factory(:group, :public => false)
    login_as :quentin
    get :show, :id => group
    assert_response :redirect
  end
  
  test "should show private group to member" do
    group = Factory(:group, :public => false)
    group.add_member users(:aaron)
    
    login_as :aaron
    get :show, :id => group
    assert_response :success    
  end
  
  
  
end
