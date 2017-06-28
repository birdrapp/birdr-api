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
      let (:bird_params) { FactoryGirl.attributes_for(:bird) }

      it "saves the bird in the database" do
        expect {
          post "/birds", params: json_params(bird_params), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json"  }
        }.to change { Bird.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end
      it "returns the bird in the response" do
        post "/birds", params: json_params(bird_params), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }

        expect(response).to have_http_status(:created)
        expect(json_body.keys).to eq [:id, :commonName, :scientificName]
        expect(json_body[:id]).to eq Bird.last.id
        expect(json_body[:commonName]).to eq bird_params[:common_name]
        expect(json_body[:scientificName]).to eq bird_params[:scientific_name]
      end

      context "invalid bird" do
        let (:invalid_bird_params) { FactoryGirl.attributes_for :bird, :invalid }
        it "doesn't save to the database" do
          expect {
            post "/birds", params: json_params(invalid_bird_params), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
          }.to_not change { Bird.count }.from(0)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns a list of errors" do
          post "/birds", params: json_params(invalid_bird_params), headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_body[:errors][:common_name]).to include "can't be blank"
        end
      end
    end
  end
end
