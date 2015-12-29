class Api::V1::PresentsController < ApplicationController
  respond_to :json #this is like saying "hey PresentsController, you respond to/handle json"
  def index
    render json: ""
  end

end
