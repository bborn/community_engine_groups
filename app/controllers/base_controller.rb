class BaseController < ApplicationController

  def current_group
    @group = Group.find(params[:group_id])
    return @group
  end

  def find_group
    return current_group
  end

  def current_group_owner
    if find_group.owner == current_user
      return current_user
    end
  return false
  end
  
end