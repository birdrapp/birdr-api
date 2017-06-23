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
      end

      it "returns a 201 for a valid email" do
        post :create_reset_token, params: { email: user.email }
        expect(response).to have_http_status(201)
      end

      it "ignores the case of the email address" do
        post :create_reset_token, params: { email: user.email }
        expect(response).to have_http_status(201)
      end

      it "generates a password reset token for the user" do
        user = FactoryGirl.create :user, password_reset_digest: nil

        expect {
          post :create_reset_token, params: { email: user.email }
          user.reload
        }.to change(user, :password_reset_digest)
      end

      it "sends a password reset email to the user" do
        expect {
          post :create_reset_token, params: { email: user.email }
        }.to change { ActionMailer::Base.deliveries.length }.by(1)
        last_mail_sent = ActionMailer::Base.deliveries.last

        expect(last_mail_sent.to).to include user.email
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
      expired_token_user = FactoryGirl.create :user, :expired_password_reset
      params[:email] = expired_token_user.email

      patch :update, params: params
      expect(response).to have_http_status(401)
    end

    it "returns a 401 for an invalid reset token" do
      params[:password_reset_token] = 'invalid'

      patch :update, params: params
      expect(response).to have_http_status(401)
    end

    describe "valid password reset" do
      before :each do
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
          user.reload
        }.to change { user.password_digest }
      end

      it "removes all the user's tokens" do
        5.times { user.tokens.create }
        expect {
          patch :update, params: params
        }.to change { user.tokens.count }.from(5).to(0)
      end

      it "removes the password_reset_digest" do
        expect {
          patch :update, params: params
          user.reload
        }.to change { user.password_reset_digest }.to(nil)
      end
    end
  end

end
