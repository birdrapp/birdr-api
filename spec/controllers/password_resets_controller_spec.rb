require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do

  describe "POST #create" do
    it "returns a 404 for an unknown email" do
      post :create, params: { email: 'not.going@to.find.me' }
      expect(response).to have_http_status(404)
    end

    describe "valid password resets" do
      let(:user) { FactoryGirl.create :user }

      before :each do
        expect(User).to receive(:find_by).with({ email: user.email.downcase }).and_return(user)
        allow(user).to receive(:generate_password_reset_token)
        allow(user).to receive(:send_password_reset_email)
      end

      it "returns a 201 for a valid user" do
        post :create, params: { email: user.email }
        expect(response).to have_http_status(201)
      end

      it "ignores the case of the email address" do
        post :create, params: { email: user.email.upcase! }
        expect(response).to have_http_status(201)
      end

      it "generates a password reset token for the user" do
        expect(user).to receive(:generate_password_reset_token)
        post :create, params: { email: user.email }
      end

      it "sends a password reset email to the user" do
        expect(user).to receive(:send_password_reset_email)
        post :create, params: { email: user.email }
      end
    end
  end

  describe "PATCH #update" do
    let(:user) { FactoryGirl.create :user }

    it "returns a 401 for an unknown user" do
      patch :update, params: { id: user.password_reset_token, email: 'invalid@no.com' }
      expect(response).to have_http_status(401)
    end

    it "returns a 401 for an expired reset token" do
      expect(User).to receive(:find_by).with({email: user.email}).and_return(user)
      expect(user).to receive(:authenticated?).and_return(true)
      expect(user).to receive(:password_reset_token_expired?).and_return(true)

      patch :update, params: { email: user.email, id: user.password_reset_token }
      expect(response).to have_http_status(401)
    end

    it "returns a 401 for an invalid reset token" do
      user.password_reset_token = 'bang!'
      expect(User).to receive(:find_by).with({email: user.email}).and_return(user)
      allow(user).to receive(:password_reset_token_expired?).and_return(false)
      expect(user).to receive(:authenticated?).and_return(false)

      patch :update, params: { email: user.email, id: user.password_reset_token, password: 'muhahahaha' }
      expect(response).to have_http_status(401)
    end

    describe "valid user" do
      before :each do
        expect(User).to receive(:find_by).with({email: user.email}).and_return(user)
        expect(user).to receive(:password_reset_token_expired?).and_return(false)
        expect(user).to receive(:authenticated?).and_return(true)
      end

      it "downcases the email" do
        patch :update, params: { email: user.email.upcase, id: user.password_reset_token, password: 'secret' }
      end

      it "returns a 422 for a blank password" do
        patch :update, params: { email: user.email, id: user.password_reset_token, password: '' }
        expect(response).to have_http_status(422)
      end

      it "returns a 422 for a valid user but an invalid password" do
        patch :update, params: { email: user.email, id: user.password_reset_token, password: 'no' }
        expect(response).to have_http_status(422)
        expect(json[:errors][:password]).to eq ["is too short (minimum is 6 characters)"]
      end

      it "on success changes the users password" do
        expect {
          patch :update, params: { email: user.email, id: user.password_reset_token, password: 'veryvalid' }
        }.to change { user.password_digest }
      end

      it "on success it deletes all the users tokens" do
        5.times { user.tokens.create }
        expect {
          patch :update, params: { email: user.email, id: user.password_reset_token, password: 'supervalidsecret' }
        }.to change { user.tokens.count }.from(5).to(0)
      end

      it "on success removes the password_reset_digest" do
        user.password_reset_digest = 'blah'
        expect {
          patch :update, params: { email: user.email, id: user.password_reset_token, password: 'supervalidsecret' }
          user.reload
        }.to change { user.password_reset_digest }.from('blah').to(nil)

        expect(response).to have_http_status 200
      end
    end
  end
end
