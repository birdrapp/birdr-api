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

  describe "class methods" do
    describe ".find_by_token" do
      it 'returns a user belonging to a given token' do
        user = FactoryGirl.create :user
        token = user.tokens.create

        expect(User.find_by_token(token)).to eq user
      end

      it 'returns a user with a given token ID' do
        user = FactoryGirl.create :user
        token = user.tokens.create

        expect(User.find_by_token(token.id)).to eq user
      end

      it 'returns nil if a user is not associated with a token' do
        expect(User.find_by_token('nadda')).to be_nil
      end
    end
  end
end
