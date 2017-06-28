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

        get "/user", headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect(json[:first_name]).to eq(user.first_name)
        expect(json[:last_name]).to eq(user.last_name)
        expect(json[:email]).to eq(user.email)
      end
    end
  end

  describe "POST /users" do
    let (:user_params) { FactoryGirl.attributes_for(:user) }

    it "saves the user in the database" do
      expect {
        post "/users", params: user_params
      }.to change { User.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
    end

    it "returns the new user in the response" do
      post "/users", params: user_params

      expect(response).to have_http_status(:created)

      expect(json.keys).to eq [:id, :first_name, :last_name, :email]
      expect(json[:first_name]).to eq user_params[:first_name]
      expect(json[:last_name]).to eq user_params[:last_name]
      expect(json[:email]).to eq user_params[:email]
      expect(json[:id]).to eq User.last.id
    end

    it "does not return the password in the response" do
      post "/users", params: user_params

      expect(response).to have_http_status(:created)

      expect(json[:password]).to be nil
      expect(json[:password_digest]).to be nil
    end

    context "failure scenarios" do
      let (:invalid_params) { FactoryGirl.attributes_for :user, :invalid_email }

      it "does not save an invalid user to the database" do
        expect {
          post "/users", params: invalid_params
        }.to_not change { User.count }
      end

      it "returns a 422 for an invalid user" do
        post "/users", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a list of errors in the response" do
        post "/users", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)

        expect(json[:errors][:email]).to include "is invalid"
      end
    end
  end

  describe "DELETE /user" do
    context "unauthenticated users" do
      it "returns a 401" do
        delete "/user"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      it "deletes the user" do
        user = FactoryGirl.create :user
        expect {
          delete "/user", headers: auth_headers(user)
        }.to change { User.count }.from(1).to(0)

        expect(User.find_by(id: user.id)).to be nil
        expect(response).to have_http_status(:no_content)
      end

      it "deletes the user's access tokens" do
        user = FactoryGirl.create :user
        user.tokens.create

        expect {
          delete "/user", headers: auth_headers(user)
        }.to change { user.tokens.count }.from(1).to(0)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "PATCH /user" do
    context "unauthenticated users" do
      it "returns a 401" do
        patch "/user"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      let (:user) { FactoryGirl.create :user }

      it "updates the user with new values" do
        patch "/user", params: {first_name: "new", last_name: "name"}, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        user.reload
        expect(user.first_name).to eq("new")
        expect(user.last_name).to eq("name")
      end

      it "doesn't allow a user to update their password" do
        expect {
          patch "/user", params: {password: "something_new"}, headers: auth_headers(user)
          user.reload
        }.to_not change { user.password_digest }
      end

      it "doesn't allow a user to update their email" do
        expect {
          patch "/user", params: {email: "new@email.com"}, headers: auth_headers(user)
          user.reload
        }.to_not change { user.email }
      end

      it "returns a 422 for invalid values" do
        patch "/user", params: { first_name: nil }, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
