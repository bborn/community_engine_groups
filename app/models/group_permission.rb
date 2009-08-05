class GroupPermission < ActiveRecord::Base
  belongs_to :group_role
  belongs_to :membership
end
