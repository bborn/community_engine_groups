class Comment < ActiveRecord::Base

  # def self.find_groupphoto_comments_for(group)
  #   Comment.find(:all, :conditions => ["recipient_id = ? AND commentable_type = ?", group.owner.id, 'Groupphoto'], :order => 'created_at DESC')
  # end
  # 
  # def self.find_group_comments_for(group)
  #   Comment.find(:all, :conditions => ["recipient_id = ? AND commentable_type = ?", group.owner.id, 'Group'], :order => 'created_at DESC')
  # end
  # 
  # def self.find_comments_by_group(group, *args)
  #   options = args.extract_options!
  #   find(:all,
  #     :conditions => ["commentable_id = ?", group.id],
  #     :order => "created_at DESC",
  #     :limit => options[:limit]
  #   )
  # end

end