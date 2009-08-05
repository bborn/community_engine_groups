require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :all

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_should_create_group
    assert_difference Group, :count do
      group = create_group
      assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
    end
  end

  def test_should_reject_blank_name
    group = Group.new()
    assert !group.valid?
    assert group.errors.on(:name)
  end

  def test_should_not_reject_spaces
    group = Group.new(:name => 'foo bar')
    group.valid?
    assert !group.errors.on(:name)
  end

  def test_should_reject_special_chars
    group = Group.new(:name => '&stripes')
    assert !group.valid?
    assert group.errors.on(:name)
  end

  def test_should_accept_normal_chars_in_name
    u = create_group(:name => "foo_and_bar")
    assert !u.errors.on(:name)
    u = create_group(:name => "2foo-and-bar")
    assert !u.errors.on(:name)
  end

  def test_should_show_location
    assert_equal groups(:GroupOne).location, metro_areas(:twincities).name
  end

  def test_should_return_full_location
    assert_equal "Minneapolis / St. Paul", groups(:GroupOne).full_location
  end


  def test_should_call_avatar_photo
    assert_equal groups(:GroupOne).avatar_photo_url, AppConfig.photo['missing_medium']
    assert_equal groups(:GroupOne).avatar_photo_url(:thumb), AppConfig.photo['missing_thumb']
  end

  
  protected
  def create_group(options = {})
    Group.create({ :name => 'Group 2' }.merge(options))
  end


end