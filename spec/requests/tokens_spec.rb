require "rails_helper"

RSpec.describe "Tokens", type: :request do
  describe "POST /tokens" do
    let (:user) { FactoryGirl.create :user }

    context "failed authentication" do
      it "returns a 401 for an invalid user" do
        post "/tokens", params: json_params({ email: "in@valid.com", password: user.password }), headers: { 'Content-Type': 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
      it "returns a 401 for an incorrect password" do
        post "/tokens", params: json_params({ email: user.email, password: "nope" }), headers: { 'Content-Type': 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
      it "returns a formatted error" do
        post "/tokens", params: json_params({ email: user.email }), headers: { 'Content-Type': 'application/json' }
        expect(response).to have_http_status(:unauthorized)
        expect(json_body[:errors][:account]).to eq "Unauthorized"
      end
    end

    context "successful authentication" do
      it "creates a new token" do
        expect {
          post "/tokens", params: json_params({ email: user.email, password: user.password }), headers: { 'Content-Type': 'application/json' }
        }.to change { user.tokens.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "ignores case on users email" do
        expect {
          post "/tokens", params: json_params({ email: user.email.upcase, password: user.password }), headers: { 'Content-Type': 'application/json' }
        }.to change { user.tokens.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "returns the token ID in the response" do
        post "/tokens", params: json_params({ email: user.email, password: user.password }), headers: { 'Content-Type': 'application/json' }
        token = Token.last

        expect(json_body[:token]).to eq token.id
      end
      it "returns the user object in the response" do
        post "/tokens", params: json_params({ email: user.email, password: user.password }), headers: { 'Content-Type': 'application/json' }

        expect(response).to have_http_status(:created)

        expect(json_body[:user]).to_not be_nil
        expect(json_body[:user][:firstName]).to eq user.first_name
        expect(json_body[:user][:lastName]).to eq user.last_name
        expect(json_body[:user][:email]).to eq user.email
      end
    end
  end
end
