class Comment < ActiveRecord::Base

  def can_be_deleted_by(person)    
    if person
      return true if (person.admin? || person.id.eql?(user_id) || person.id.eql?(recipient_id) )
      return true if commentable_type.eql?('Group') && commentable.is_owned_by?(person)
    end
    false
  end
  
end