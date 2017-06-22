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
      expect(json[:first_name]).to eq(user[:first_name])
      expect(json[:last_name]).to eq(user[:last_name])
      expect(json[:email]).to eq(user[:email])
    end
  end

  describe 'POST #create' do
    let (:user_params)         { FactoryGirl.attributes_for(:user) }
    let (:invalid_user_params) { FactoryGirl.attributes_for(:user, :invalid_email) }

    it 'saves the user in the database' do
      expect {
        post :create, params: user_params
      }.to change { User.count }.from(0).to(1)

      expect(response).to have_http_status(201)
    end

    it 'returns the new user in the response' do
      post :create, params: user_params
      last_created_user = User.last

      expect(response).to have_http_status(201)

      expect(json.keys).to eq [:id, :first_name, :last_name, :email]

      expect(json[:first_name]).to eq(user_params[:first_name])
      expect(json[:last_name]).to eq(user_params[:last_name])
      expect(json[:email]).to eq(user_params[:email])
      expect(json[:id]).to eq(last_created_user[:id])
    end

    it 'it does not return the password in the response' do
      post :create, params: user_params

      expect(response).to have_http_status(201)

      expect(json[:password]).to be nil
      expect(json[:password_digest]).to be nil
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

        expect(json[:errors][:email]).to include('is invalid')
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

      expect(User.find_by id: user.id).to be_nil
      expect(response).to have_http_status(204)
    end

    it 'deletes the user\'s access tokens' do
      user = FactoryGirl.create :user
      user.tokens.create

      sign_in_as user
      expect {
        delete :destroy
      }.to change { user.tokens.count }.from(1).to(0)
    end
  end

  describe 'PATCH #update' do
    let(:valid_user) { FactoryGirl.create :user }

    it 'returns a 401 for unauthenticated users' do
      patch :update, params: { email: 'new@mail.com' }
      expect(response).to have_http_status(401)
    end

    it 'updates the user with the new values' do
      sign_in_as valid_user
      patch :update, params: { first_name: 'new', last_name: 'name' }

      expect(response).to have_http_status(200)
      expect(valid_user.first_name).to eq('new')
      expect(valid_user.last_name).to eq('name')
    end

    it 'doesn\'t allow a user to update their password' do
      sign_in_as valid_user

      expect {
        patch :update, params: { password: 'my new password' }
      }.to_not change { valid_user.password_digest }
    end

    it 'doesn\'t allow a user to update their email' do
      sign_in_as valid_user
      expect {
        patch :update, params: { email: 'new@mail.com' }
      }.to_not change { valid_user.email }
    end

    it 'returns a 422 if provided invalid values' do
      sign_in_as valid_user
      allow_any_instance_of(User).to receive(:save).and_return(false)

      patch :update, params: { first_name: 'invalid' }
      expect(response).to have_http_status(422)
    end
  end

end
