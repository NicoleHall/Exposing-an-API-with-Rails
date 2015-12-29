require 'rails_helper'
RSpec.describe Api::V1::PresentsController, :type => :controller do
  describe "get #index" do
    
    it "returns all of the Presents.all" do
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to eq(Present.all.to_json)
    end
  end
end
