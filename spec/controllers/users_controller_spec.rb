require 'rails_helper'

RSpec.describe UsersController, type: :controller do

describe 'GET #show' do
  it 'returns a 401 for unauthenticated users' do
    get :show
    expect(response).to have_http_status(401)
  end

  it 'returns the user object for authenticated users' do
    user = FactoryGirl.create :user

    sign_in_as user
    get :show

    expect(response).to have_http_status(200)
    expect(json['first_name']).to eq(user['first_name'])
    expect(json['last_name']).to eq(user['last_name'])
    expect(json['email']).to eq(user['email'])
  end
end

describe 'POST #create' do
  let (:user_params)         { FactoryGirl.attributes_for(:user) }
  let (:invalid_user_params) { FactoryGirl.attributes_for(:user, :invalid_email) }

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

      expect(body['errors']['email']).to include('is invalid')
    end
  end

end

describe 'DELETE #destroy' do
  it 'returns a 401 for unauthenticated users' do
    delete :destroy
    expect(response).to have_http_status(401)
  end

  it 'deletes an authenticated user' do
    user = FactoryGirl.create :user

    sign_in_as user
    expect {
      delete :destroy
    }.to change { User.count }.from(1).to(0)

    expect(response).to have_http_status(204)
  end
end

end
