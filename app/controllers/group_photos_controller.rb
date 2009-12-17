class GroupPhotosController < BaseController
  resource_controller
  belongs_to :group

  def object_name
    'photo'
  end
  
  def model_name
    'photo'
  end
  
  def resource_name
    'photo'
  end
  
  def route_name
    'photo'
  end
  
  
end
