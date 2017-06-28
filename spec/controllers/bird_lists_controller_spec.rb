require 'rails_helper'

RSpec.describe BirdListsController, type: :controller do
  describe "GET #show" do

    it "returns a 401 for unauthenticated users" do
      get :show
      expect(response).to have_http_status(401)
    end

    context "authenticated users" do
      let (:user) { FactoryGirl.create :user }
      before :each do
        sign_in_as user
        20.times { FactoryGirl.create :bird }
      end

      it "returns a list of all birds" do
        get :show
        expect(response).to have_http_status(200)

        expect(json.length).to eq Bird.count
        returned_ids = json.map {|item| item[:bird][:id] }
        expected_ids = Bird.pluck(:id)

        expect(returned_ids).to eq expected_ids
      end

      it "indicates whether the user has seen the bird or not" do
        seen_birds = Bird.all.sample(3)
        seen_birds.each { |bird| user.sightings.create bird_id: bird.id }
        seen_birds_ids = seen_birds.pluck(:id)

        get :show

        expect(response).to have_http_status(200)

        json.each do |bird_list_item|
          bird_id = bird_list_item[:bird][:id]
          if bird_id.in? seen_birds_ids
            expect(bird_list_item[:seen]).to eq true
          else
            expect(bird_list_item[:seen]).to eq false
          end
        end
      end

    end
  end
end
