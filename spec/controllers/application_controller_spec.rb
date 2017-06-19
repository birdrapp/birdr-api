require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      head 200
    end
  end

  describe "authentication" do
    let (:valid_user) { FactoryGirl.create :user }

    it 'returns a 401 when no token is provided' do
      get :index
      expect(response).to have_http_status(401)
    end

    it 'returns a 401 for a user with an invalid token' do
      send_invalid_token
      get :index
      expect(response).to have_http_status(401)
    end

    it 'returns a formatted error' do
      send_invalid_token
      get :index
      expect(json['errors']['account']).to eq('Unauthorized')
    end

    it 'returns a 200 when a valid token is provided' do
      sign_in_as valid_user
      get :index
      expect(response).to have_http_status(200)
    end
  end
end
