class UserNotifier < ActionMailer::Base

  def membership_request(membership)
    setup_email(membership.group.owner)
    @subject     += "#{membership.user.login} would like to be a fan of #{membership.group.name}!."
    @body[:url]  = pending_group_memberships_url(membership.group)
    @body[:requester] = membership.group.owner
  end

end