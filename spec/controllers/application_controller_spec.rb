require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      head 200
    end
  end

  describe "authentication" do
    it 'returns a 401 when no token is provided' do
      get :index
      expect(response).to have_http_status(401)
    end

    it 'returns a 401 for a user with an invalid token' do
      request.headers.merge!({ Authorization: 'nope' })
      get :index
      expect(response).to have_http_status(401)
    end

    it 'returns a 401 when the token has expired' do
      token = FactoryGirl.create :token, expires_at: Time.now - 1.minute
      request.headers.merge!({ Authorization: "Bearer #{token}"})
      get :index
      expect(response).to have_http_status 401
    end

    it 'returns a formatted error' do
      request.headers.merge!({ Authorization: 'nope' })
      get :index
      expect(json[:errors][:account]).to eq('Unauthorized')
    end

    it 'returns a 200 when a valid token is provided' do
      token = FactoryGirl.create :token
      request.headers.merge!({ Authorization: "Bearer #{token}"})
      get :index
      expect(response).to have_http_status(200)
    end
  end
end
