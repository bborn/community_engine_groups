class GroupPhoto < Asset
  has_attachment prepare_options_for_attachment_fu(AppConfig.photo['attachment_fu_options'])  
  validates_as_attachment  
  
end