class Api::V1::PresentsController < Api::V1::BaseController
  #respond_to :json #this is like saying "hey PresentsController, you respond to/handle json"
  def model_class
    Present
  end

end
