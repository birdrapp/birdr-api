require 'rails_helper'

RSpec.describe BirdsController, type: :controller do

  describe "POST #create" do
    let (:bird_params) { FactoryGirl.attributes_for :bird }

    it "returns a 401 for unauthenticated users" do
      post :create, params: bird_params
      expect(response).to have_http_status 401
    end

    it "saves the bird in the database" do
      sign_in

      expect {
        post :create, params: bird_params
      }.to change { Bird.count }.from(0).to(1)

      expect(response).to have_http_status 201
    end

    it "returns the bird object" do
      sign_in

      post :create, params: bird_params

      expect(json.keys).to eq [:id, :common_name, :scientific_name]

      expect(json[:id]).to eq Bird.last.id # expect the last generated ID
      expect(json[:common_name]).to eq bird_params[:common_name]
      expect(json[:scientific_name]).to eq bird_params[:scientific_name]
    end

    describe 'failures' do
      let (:invalid_bird_params) { FactoryGirl.attributes_for :bird, :invalid }

      before :each do
        sign_in
      end

      it 'does not save an invalid bird into the database' do
        expect {
          post :create, params: invalid_bird_params
        }.to_not change { Bird.count }
      end

      it 'returns a 422 for an invalid bird' do
        post :create, params: invalid_bird_params
        expect(response).to have_http_status 422
      end

      it 'returns a list of errors' do
        post :create, params: invalid_bird_params
        expect(json[:errors][:common_name]).to include "can't be blank"
      end
    end
  end

end
