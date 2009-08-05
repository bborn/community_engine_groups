module BaseHelper

  def add_member_link(group = nil)
		html = "<span class='member_request' id='member_request_#{group.id}'>"
    html += link_to_remote :request_membership.l,
				{:update => "member_request_#{group.id}",
					:loading => "$$('span#member_request_#{group.id} span.spinner')[0].show(); $$('span#member_request_#{group.id} a.add_member_btn')[0].hide()",
					:complete => visual_effect(:highlight, "member_request_#{group.id}", :duration => 1),
          500 => "alert('"+:sorry_there_was_an_error_requesting_membership.l+"')",
					:url => hash_for_group_memberships_url(:group_id => group.id, :user_id => current_user.id),
					:method => :post }, {:class => "add_member button"}
		html +=	"<span style='display:none;' class='spinner'>"
		html += image_tag 'spinner.gif', :plugin => "community_engine"
		html += :requesting_membership.l+" ...</span></span>"
		html
  end

end
