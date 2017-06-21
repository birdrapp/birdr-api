require 'rails_helper'

RSpec.describe TokensController, type: :controller do

  describe "POST #create" do
    let (:valid_user) { FactoryGirl.create :user }

    describe "for valid users" do
      it "creates a new token for that user" do
        expect {
          post :create, params: { email: valid_user.email, password: valid_user.password }
        }.to change { valid_user.tokens.count }.from(0).to(1)

        expect(response).to be_success
        expect(response).to have_http_status(201)
      end

      it "ignores case on users password" do
        post :create, params: { email: valid_user.email.upcase, password: valid_user.password }

        expect(response).to be_success
        expect(response).to have_http_status(201)
      end

      it "returns the token ID in the response" do
        post :create, params: { email: valid_user.email, password: valid_user.password }
        newly_created_token = Token.order(:created_at).last

        expect(json).to eq({ token: newly_created_token.id })
      end
    end

    describe "for failed authentication" do
      it "invalid user returns a 401" do
        post :create, params: { email: 'in@valid.com', password: valid_user.password }
        expect(response).to have_http_status(401)
      end

      it "incorrect password returns a 401" do
        post :create, params: { email: valid_user.email, password: 'not-quite-right' }
        expect(response).to have_http_status(401)
      end

      it "returns a formatted error" do
        post :create, params: { email: valid_user.email, password: 'not-quite-right' }
        expect(response).to have_http_status(401)
        expect(json[:errors][:account]).to eq 'Unauthorized'
      end
    end
  end

end
