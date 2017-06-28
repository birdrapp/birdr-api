require "rails_helper"

RSpec.describe "Password Resets", type: :request do
  describe "POST /password_resets" do
    let (:user) { FactoryGirl.create :user, password_reset_digest: nil }

    it "returns 404 for unknown emails" do
      post "/password_resets", params: { email: 'no@no.no'}
      expect(response).to have_http_status(:not_found)
    end

    it "generates a password reset token for the user" do
      expect {
        post "/password_resets", params: { email: user.email }
        user.reload
      }.to change(user, :password_reset_digest)
      expect(response).to have_http_status(:created)
    end

    it "ignores case on email" do
      post "/password_resets", params: { email: user.email.upcase }
      expect(response).to have_http_status(:created)
    end

    it "sends a password reset email to the user" do
      user = FactoryGirl.create :user
      expect {
        post "/password_resets", params: { email: user.email }
      }.to change { ActionMailer::Base.deliveries.length }.by(1)
      last_mail = ActionMailer::Base.deliveries.last

      expect(last_mail.to).to include user.email
    end
  end

  describe "PATCH /password_resets" do
    let (:user) { FactoryGirl.create :user }

    before :each do
      @params = {
        password: 'supersecret',
        email: user.email
      }
    end

    it "returns 401 for unknown emails" do
      @params[:email] = 'no@no.com'
      patch "/password_resets/#{user.password_reset_token}", params: @params

      expect(response).to have_http_status(:unauthorized)
    end
    it "returns 401 for an invalid reset token" do
      patch "/password_resets/invalid", params: @params
      expect(response).to have_http_status(:unauthorized)
    end
    it "returns 401 for an expired token" do
      expired_token_user = FactoryGirl.create :user, :expired_password_reset
      @params[:email] = expired_token_user.email

      patch "/password_resets/#{expired_token_user.password_reset_token}", params: @params
      expect(response).to have_http_status(:unauthorized)
    end

    context "valid user and reset token" do
      it "downcases the email" do
        @params[:email] = user.email.upcase
        patch "/password_resets/#{user.password_reset_token}", params: @params
        expect(response).to have_http_status(:no_content)
      end
      it "returns 422 for a blank password" do
        @params[:password] = '      '
        patch "/password_resets/#{user.password_reset_token}", params: @params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 for an invalid password" do
        @params[:password] = 'short'
        patch "/password_resets/#{user.password_reset_token}", params: @params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body[:errors][:password]).to include /too short/
      end

      it "changes the user's password" do
        expect {
          patch "/password_resets/#{user.password_reset_token}", params: @params
          user.reload
        }.to change { user.password_digest }
        expect(response).to have_http_status(:no_content)
      end

      it "removes all the user's access tokens" do
        5.times { user.tokens.create }
        expect {
          patch "/password_resets/#{user.password_reset_token}", params: @params
        }.to change { user.tokens.count }.from(5).to(0)
        expect(response).to have_http_status(:no_content)
      end

      it "cannot reuse the password reset token" do
        patch "/password_resets/#{user.password_reset_token}", params: @params
        expect(response).to have_http_status(:no_content)
        patch "/password_resets/#{user.password_reset_token}", params: @params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
