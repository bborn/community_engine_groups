module MembershipsHelper

  def membership_control_links(membership)
    case membership.membership_status_id
      when MembershipStatus[:pending].id
        "#{(link_to(:accept.l, accept_group_membership_path(membership.group, membership), :method => :put, :class => 'button positive') unless !membership.initiator?)} #{link_to( 'Deny', deny_group_membership_path(membership.group, membership), :method => :put, :class => 'button negative')}"
      when MembershipStatus[:accepted].id
        "#{link_to(:remove_this_member.l, deny_group_membership_path(membership.group, membership), :method => :put, :class => 'button negative')}"
      when MembershipStatus[:denied].id
    		"#{link_to(:accept_this_request.l, accept_group_membership_path(membership.group, membership), :method => :put, :class => 'button positive')}"
    end
  end

end
