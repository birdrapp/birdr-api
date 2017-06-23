require 'rails_helper'

RSpec.describe SightingsController, type: :controller do

  describe "POST #create" do
    it "returns a 401 for an unauthenticated user" do
      post :create
      expect(response).to have_http_status(401)
    end

    describe "authenticated user" do
      let (:user) { FactoryGirl.create :user }
      let (:bird) { FactoryGirl.create :bird }

      before :each do
        sign_in_as user
      end

      it "returns a 422 if no bird_id is sent" do
        post :create, params: {}
        expect(response).to have_http_status(422)
      end

      it "returns a 422 if an invalid bird_id is sent" do
        post :create, params: { bird_id: '422' }
        expect(response).to have_http_status(422)
        expect(json[:errors][:bird_id]).to eq ['can\'t be blank']
      end

      it "creates a sighting and returns 201" do
        expect {
          post :create, params: { bird_id: bird.id }
        }.to change { Sighting.count }.from(0).to(1)

        expect(response).to have_http_status(201)
      end

      it "returns the sighting in the response" do
        post :create, params: { bird_id: bird.id }

        expect(json[:id]).to eq Sighting.last.id

        expect(json[:bird][:id]).to eq bird.id
        expect(json[:bird][:common_name]).to eq bird.common_name

        expect(json[:user][:id]).to eq user.id
        expect(json[:user][:first_name]).to eq user.first_name
        expect(json[:user][:last_name]).to eq user.last_name
      end

      it "returns a 422 if a user tries to add the same bird twice" do
        post :create, params: { bird_id: bird.id }
        expect(response).to have_http_status 201

        post :create, params: { bird_id: bird.id }
        expect(response).to have_http_status 422
        expect(json[:errors][:bird_id]).to eq ['bird already in list of sightings']
      end
    end
  end

  describe "DELETE #destroy" do
    it "returns a 401 for an unauthenticated user" do
      delete :destroy, params: { id: 'blah' }
      expect(response).to have_http_status(401)
    end

    it "returns a 401 if a user tries to delete another users sighting" do
      user = FactoryGirl.create :user
      bird = FactoryGirl.create :bird
      sneaky_user = FactoryGirl.create :user
      sighting = Sighting.create user_id: user.id, bird_id: bird.id

      sign_in_as sneaky_user

      expect {
        delete :destroy, params: { id: sighting.id }
      }.to_not change { user.sightings.count }
      expect(response).to have_http_status 401
    end

    describe "authenticated user" do
      let (:user) { FactoryGirl.create :user }
      let (:bird) { FactoryGirl.create :bird }

      before :each do
        sign_in_as user
        @sighting = Sighting.create user_id: user.id, bird_id: bird.id
      end

      it "returns a 404 if passed an invalid sighting_id" do
        delete :destroy, params: { id: 'nope' }
        expect(response).to have_http_status(404)
      end

      it "removes the sighting and returns 204" do
        expect {
          delete :destroy, params: { id: @sighting.id }
        }.to change { user.sightings.count }.from(1).to(0)

        expect(response).to have_http_status(204)
      end
    end
  end

end
