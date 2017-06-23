require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do

  describe "POST #create_reset_token" do
    it "returns a 404 for an unknown email" do
      post :create_reset_token, params: { email: 'not@found.co.uk'}
      expect(response).to have_http_status(404)
    end

    describe "valid reset requests" do
      let (:user) { FactoryGirl.create :user }

      before :each do
        expect(User).to receive(:find_by).with({ email: user.email.downcase }).and_return(user)
        allow(user).to receive(:generate_password_reset_token)
        allow(user).to receive(:send_password_reset_email)
      end

      it "returns a 201 for a valid email" do
        post :create_reset_token, params: { email: user.email }
        expect(response).to have_http_status(201)
      end

      it "ignores the case of the email address" do
        post :create_reset_token, params: { email: user.email.upcase }
        expect(response).to have_http_status(201)
      end

      it "generates a password reset token for the user" do
        expect(user).to receive(:generate_password_reset_token)
        post :create_reset_token, params: { email: user.email }
      end

      it "sends a password reset email to the user" do
        expect(user).to receive(:send_password_reset_email)
        post :create_reset_token, params: { email: user.email }
      end
    end
  end

  describe "PATCH #update" do
    let (:user) { FactoryGirl.create :user }
    let (:params) { { new_password: 'supersecret', password_reset_token: user.password_reset_token, email: user.email } }

    it "returns a 401 for an unknown user" do
      params[:email] = 'not@found.com'

      patch :update, params: params
      expect(response).to have_http_status(401)
    end

    it "returns a 401 with an expired reset token" do
      expect(User).to receive(:find_by).with({ email: user.email }).and_return(user)
      expect(user).to receive(:authenticated?).and_return(true)
      expect(user).to receive(:password_reset_token_expired?).and_return(true)

      patch :update, params: params
      expect(response).to have_http_status(401)
    end

    it "returns a 401 for an invalid reset token" do
      params[:password_reset_token] = 'invalid'
      expect(User).to receive(:find_by).with({ email: user.email }).and_return(user)
      expect(user).to receive(:authenticated?).and_return(false)

      patch :update, params: params
      expect(response).to have_http_status(401)
    end

    describe "valid password reset" do
      before :each do
        expect(User).to receive(:find_by).with({ email: user.email }).and_return(user)
        expect(user).to receive(:password_reset_token_expired?).and_return(false)
        expect(user).to receive(:authenticated?).and_return(true)
      end

      it "downcases the email" do
        params[:email] = user.email.upcase
        patch :update, params: params
        expect(response).to have_http_status(200)
      end

      it "returns a 422 for a blank password" do
        params[:new_password] = '  '
        patch :update, params: params
        expect(response).to have_http_status(422)
      end

      it "returns a 422 for a valid user but an invalid password" do
        params[:new_password] = 'short'
        patch :update, params: params
        expect(response).to have_http_status(422)
        expect(json[:errors][:password]).to eq ["is too short (minimum is 6 characters)"]
      end

      it "changes the user's password" do
        expect {
          patch :update, params: params
        }.to change { user.password_digest }
      end

      it "removes all the user's tokens" do
        5.times { user.tokens.create }
        expect {
          patch :update, params: params
        }.to change { user.tokens.count }.from(5).to(0)
      end

      it "removes the password_reset_digest" do
        user.password_reset_digest = 'blah'
        expect {
          patch :update, params: params
        }.to change { user.password_reset_digest }.from('blah').to(nil)
      end
    end
  end

end
