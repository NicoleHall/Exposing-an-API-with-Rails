class Api::V1::WrappingsController < Api::V1::BaseController
  respond_to :json #this is like saying "hey wrapppingController, you respond to/handle json"
  def model_class
    Wrapping
  end

end
