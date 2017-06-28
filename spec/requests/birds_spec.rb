require "rails_helper"

RSpec.describe "Birds", type: :request do
  describe "POST /birds" do
    context "unauthenticated users" do
      it "returns a 401" do
        post "/birds"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      let (:user) { FactoryGirl.create :user }
      let (:bird_params) { FactoryGirl.attributes_for :bird }

      it "saves the bird in the database" do
        expect {
          post "/birds", params: bird_params, headers: auth_headers(user)
        }.to change { Bird.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "returns the bird in the response" do
        post "/birds", params: bird_params, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect(json.keys).to eq [:id, :common_name, :scientific_name]
        expect(json[:id]).to eq Bird.last.id
        expect(json[:common_name]).to eq bird_params[:common_name]
        expect(json[:scientific_name]).to eq bird_params[:scientific_name]
      end

      context "invalid bird" do
        let (:invalid_bird_params) { FactoryGirl.attributes_for :bird, :invalid }
        it "doesn't save to the database" do
          expect {
            post "/birds", params: invalid_bird_params, headers: auth_headers(user)
          }.to_not change { Bird.count }.from(0)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns a list of errors" do
          post "/birds", params: invalid_bird_params, headers: auth_headers(user)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json[:errors][:common_name]).to include "can't be blank"
        end
      end
    end
  end
end
