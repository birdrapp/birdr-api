require "rails_helper"

RSpec.describe "Bird Lists", type: :request do
  describe "GET /user/bird_list" do
    let (:user) { FactoryGirl.create :user }

    context "unauthenticated users" do
      it "returns a 401" do
        get "/user/bird_list"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated users" do
      before :each do
        20.times { FactoryGirl.create :bird }
      end

      it "returns a list of all birds" do
        get "/user/bird_list", headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }
        expect(response).to have_http_status(:success)
        expect(json_body.length).to eq Bird.count
        returned_ids = json_body.map { |item| item[:bird][:id] }
        expected_ids = Bird.pluck(:id)

        expect(returned_ids).to eq(expected_ids)
      end
      it "marks birds seen by the user" do
        seen_birds = Bird.all.sample(3)
        seen_birds.each { |bird| user.sightings.create bird_id: bird.id }
        seen_bird_ids = seen_birds.pluck(:id)

        get "/user/bird_list", headers: { "Authorization": "Bearer #{token_for(user)}", "Content-Type": "application/json" }

        expect(response).to have_http_status(:success)

        json_body.each do |bird_list_item|
          bird_id = bird_list_item[:bird][:id]
          expect(bird_id.in? seen_bird_ids).to eq(bird_list_item[:seen])
        end
      end
    end
  end
end
