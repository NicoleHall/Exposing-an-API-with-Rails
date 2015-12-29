require 'rails_helper'
RSpec.describe Api::V1::UsersController, :type => :controller do
  describe "get #index" do
    FactoryGirl.create(:user)
    it "returns all of the users.all" do
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to eq(User.all.to_json)
    end
  end

  # describe "get #show" do
  #   let!(:id) {user.id}
  #   it "returns a single instance of the particular user" do
  #     user = FactoryGirl.build(:user, name: "Jhun")
  #     FactoryGirl.create(:user)
  #
  #     before {get :show, id: user.id}
  #
  #     expect(response.status).to eq(200)
  #     expect(response.body).to eq(user.id.to_json)
  #   end
  # end
end
