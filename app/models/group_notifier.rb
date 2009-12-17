class GroupNotifier < UserNotifier

  def membership_invitation(group_membership)
    setup_email(group_membership.user)
    @subject    += "You have been invited to join the #{group_membership.group.name} group!"
    body[:group_membership] = group_membership
    body[:url] = activate_group_membership_url(group_membership.group, group_membership)
  end

end