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
      before :each do
        allow_any_instance_of(Bird).to receive(:save).and_return(false)
        sign_in
      end

      it 'does not save an invalid bird into the database' do
        expect {
          post :create, params: bird_params
        }.to_not change { Bird.count }
      end

      it 'returns a 422 for an invalid bird' do
        post :create, params: bird_params
        expect(response).to have_http_status 422
      end

      it 'returns a list of errors' do
        expected_errors = { first_name: ['is invalid'] }
        allow_any_instance_of(Bird).to receive(:errors).and_return(expected_errors)

        post :create, params: bird_params
        expect(json[:errors]).to eq expected_errors
      end
    end
  end

end
