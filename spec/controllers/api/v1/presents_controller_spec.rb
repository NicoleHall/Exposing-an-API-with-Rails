require 'rails_helper'
RSpec.describe Api::V1::PresentsController, :type => :controller do
  describe "get #index" do
    it "returns a nice response" do
      get :index
      expect(response.status).to eq(200)
    end
  end
end
