class Api::V1::UsersController < Api::V1::BaseController
  respond_to :json #this is like saying "hey UsersController, you respond to/handle json"
  def model_class
    User
  end

end
