class Api::V1::BaseController < ApplicationController
respond_to :json
  def model_class
    #overwritten in controller
    #model_class method needs to return User.all
  end

  def index
    render json: model_class.all
  end




end
