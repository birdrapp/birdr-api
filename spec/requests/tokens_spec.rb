require "rails_helper"

RSpec.describe "Tokens", type: :request do
  describe "POST /tokens" do
    let (:user) { FactoryGirl.create :user }

    context "failed authentication" do
      it "returns a 401 for an invalid user" do
        post "/tokens", params: { email: "in@valid.com", password: user.password }
        expect(response).to have_http_status(:unauthorized)
      end
      it "returns a 401 for an incorrect password" do
        post "/tokens", params: { email: user.email, password: "nope" }
        expect(response).to have_http_status(:unauthorized)
      end
      it "returns a formatted error" do
        post "/tokens", params: { email: user.email }
        expect(response).to have_http_status(:unauthorized)
        expect(json[:errors][:account]).to eq "Unauthorized"
      end
    end

    context "successful authentication" do
      it "creates a new token" do
        expect {
          post "/tokens", params: { email: user.email, password: user.password }
        }.to change { user.tokens.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "ignores case on users email" do
        expect {
          post "/tokens", params: { email: user.email.upcase, password: user.password }
        }.to change { user.tokens.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "returns the token ID in the response" do
        post "/tokens", params: { email: user.email, password: user.password }
        token = Token.last

        expect(json[:token]).to eq token.id
      end
    end
  end
end
