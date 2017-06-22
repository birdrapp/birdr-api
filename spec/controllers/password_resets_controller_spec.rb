require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do

  describe "GET #create" do
    it "returns a 404 for an unknown email" do
      post :create, params: { email: 'not.going@to.find.me' }
      expect(response).to have_http_status(404)
    end

    describe "valid password resets" do
      let(:user) { FactoryGirl.create :user }

      before :each do
        expect(User).to receive(:find_by).and_return(user)
        allow(user).to receive(:generate_password_reset_token)
        allow(user).to receive(:send_password_reset_email)
      end

      it "returns a 201 for a valid user" do
        post :create, params: { email: user.email }
        expect(response).to have_http_status(201)
      end

      it "generates a password reset token for the user" do
        expect(user).to receive(:generate_password_reset_token)
        post :create, params: { email: user.email }
      end

      it "sends a password reset email to the user" do
        expect(user).to receive(:send_password_reset_email)
        post :create, params: { email: user.email }
      end
    end
  end

  describe "GET #update" do
    it "returns http success" do
      patch :update, params: { id: 'blah' }
      expect(response).to have_http_status(:success)
    end
  end

end
