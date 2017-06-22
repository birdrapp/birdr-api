require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'indexes' do
    it { should have_db_index(:email).unique(true) }
  end

  describe 'relationships' do
    it { should have_many(:tokens).dependent(:destroy) }
  end

  describe 'validations' do
    subject { FactoryGirl.build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_most(255) }

    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:last_name).is_at_most(255) }

    it { should validate_presence_of(:email) }
    it { should validate_length_of(:email).is_at_most(255) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('test').for(:email) }
    it { should_not allow_value('test@com').for(:email) }
    it { should_not allow_value('example.com').for(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it 'should downcase the email address' do
      mixed_case_email = 'ShOuT@mE.CoM'
      subject.update_attributes email: mixed_case_email
      assert_equal mixed_case_email.downcase, subject.reload.email
    end

    it { should have_secure_password }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe "instance methods" do
    describe "#authenticated?" do
      it "returns true when passed a valid password_reset_token" do
        user = FactoryGirl.create :user
        user.generate_password_reset_token
        token = user.password_reset_token

        expect(user.authenticated? token).to be_truthy
      end

      it "returns false when passed an invalid password_reset_token" do
        user = FactoryGirl.create :user
        user.generate_password_reset_token

        expect(user.authenticated? "nope").to be_falsy
      end
    end

    describe "#generate_password_reset_token" do
      let(:user) { FactoryGirl.create :user }

      it "sets the password_reset_token attribute" do
        expect(SecureRandom).to receive(:urlsafe_base64).and_return('my_token')

        user.password_reset_token = nil
        expect(user.password_reset_token).to be_nil
        user.generate_password_reset_token
        expect(user.password_reset_token).to eq 'my_token'
      end

      it "sets the password_reset_digest attribute" do
        expect {
          user.generate_password_reset_token
        }.to change { user.password_reset_digest }
        expect(user.password_reset_digest).to_not be_nil
      end

      it "sets the password_reset_sent_at attribute" do
        time = Time.local(2017, 6, 22, 21, 13, 0)
        travel_to time do
          user.generate_password_reset_token
          expect(user.password_reset_sent_at).to eq time
        end
      end
    end

    describe "#send_password_reset_email" do
      it "sends the password_reset mail for the user" do
        user = FactoryGirl.create :user
        mailer = double("UserMailer")

        expect(UserMailer).to receive(:password_reset).with(user).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        user.send_password_reset_email
      end
    end
  end
end
