require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /user" do
    context "unauthenticated users" do
      it "returns a 401" do
        get "/user"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      it "returns the user's profile" do
        user = FactoryGirl.create :user

        get "/user", headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }

        expect(response).to have_http_status(:success)
        expect(json_body[:firstName]).to eq(user.first_name)
        expect(json_body[:lastName]).to eq(user.last_name)
        expect(json_body[:email]).to eq(user.email)
      end
    end
  end

  describe "POST /users" do
    let (:user_params) { FactoryGirl.attributes_for(:user) }

    it "saves the user in the database" do
      expect {
        post "/users", params: json_params(user_params), headers: { "Content-Type": "application/json" }
      }.to change { User.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
    end

    it "returns the new user in the response" do
      post "/users", params: json_params(user_params), headers: { "Content-Type": "application/json" }

      expect(response).to have_http_status(:created)

      expect(json_body.keys).to eq [:id, :firstName, :lastName, :email]
      expect(json_body[:firstName]).to eq user_params[:first_name]
      expect(json_body[:lastName]).to eq user_params[:last_name]
      expect(json_body[:email]).to eq user_params[:email]
      expect(json_body[:id]).to eq User.last.id
    end

    it "does not return the password in the response" do
      post "/users", params: json_params(user_params), headers: { "Content-Type": "application/json" }

      expect(response).to have_http_status(:created)

      expect(json_body[:password]).to be nil
      expect(json_body[:password_digest]).to be nil
    end

    context "failure scenarios" do
      let (:invalid_params) { FactoryGirl.attributes_for :user, :invalid_email }

      it "does not save an invalid user to the database" do
        expect {
          post "/users", params: json_params(invalid_params), headers: { "Content-Type": "application/json" }
        }.to_not change { User.count }
      end

      it "returns a 422 for an invalid user" do
        post "/users", params: json_params(invalid_params), headers: { "Content-Type": "application/json" }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a list of errors in the response" do
        post "/users", params: json_params(invalid_params), headers: { "Content-Type": "application/json" }

        expect(response).to have_http_status(:unprocessable_entity)

        expect(json_body[:errors][:email]).to include "is invalid"
      end
    end
  end

  describe "DELETE /user" do
    context "unauthenticated users" do
      it "returns a 401" do
        delete "/user", headers: { "Content-Type": "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      it "deletes the user" do
        user = FactoryGirl.create :user
        expect {
          delete "/user", headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
        }.to change { User.count }.from(1).to(0)

        expect(User.find_by(id: user.id)).to be nil
        expect(response).to have_http_status(:no_content)
      end

      it "deletes the user's access tokens" do
        user = FactoryGirl.create :user
        user.tokens.create

        expect {
          delete "/user", headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
        }.to change { user.tokens.count }.from(1).to(0)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "PATCH /user" do
    context "unauthenticated users" do
      it "returns a 401" do
        patch "/user", headers: { "Content-Type": "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      let (:user) { FactoryGirl.create :user }

      it "updates the user with new values" do
        patch "/user", params: json_params({ first_name: "new", last_name: "name" }), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }

        expect(response).to have_http_status(:success)
        user.reload
        expect(user.first_name).to eq("new")
        expect(user.last_name).to eq("name")
      end

      it "doesn't allow a user to update their password" do
        expect {
          patch "/user", params: json_params({ password: "something_new" }), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
          user.reload
        }.to_not change { user.password_digest }
      end

      it "doesn't allow a user to update their email" do
        expect {
          patch "/user", params: json_params({ email: "new@email.com" }), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
          user.reload
        }.to_not change { user.email }
      end

      it "returns a 422 for invalid values" do
        patch "/user", params: json_params({ first_name: nil }), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
