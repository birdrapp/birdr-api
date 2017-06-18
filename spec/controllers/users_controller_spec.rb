require 'rails_helper'

RSpec.describe UsersController, type: :controller do

describe 'POST #create' do
  let (:user_params) {{ first_name: 'Matt', last_name: 'Williams', email: 'matt@williams.com', password: 'secret' }}
  let (:invalid_user_params) {{ last_name: 'Williams', email: 'matt@williams.com', password: 'secret' }}

  it 'saves the user in the database' do
    expect {
      post :create, params: user_params
    }.to change { User.count }.from(0).to(1)

    expect(response).to be_success
    expect(response).to have_http_status(201)

  end

  it 'returns the new user in the response' do
    post :create, params: user_params

    expect(response).to have_http_status(201)

    user = JSON.parse(response.body)

    expect(user['first_name']).to eq(user_params[:first_name])
    expect(user['last_name']).to eq(user_params[:last_name])
    expect(user['email']).to eq(user_params[:email])
    expect(user['id']).to_not be nil
  end

  it 'it does not return the password in the response' do
    post :create, params: user_params

    expect(response).to have_http_status(201)

    user = JSON.parse(response.body)

    expect(user['password']).to be nil
    expect(user['password_digest']).to be nil
  end

  describe 'Failures' do
    it 'does not save an invalid user to the database' do
    expect {
        post :create, params: invalid_user_params
      }.to_not change { User.count }
    end

    it 'returns a 422 for an invalid user' do
      post :create, params: invalid_user_params

      expect(response).to have_http_status(422)
    end

    it 'returns a list of errors in the response' do
      post :create, params: invalid_user_params

      expect(response).to have_http_status(422)

      body = JSON.parse(response.body)

      expect(body['errors']['first_name']).to include('can\'t be blank')
    end
  end

end

end
