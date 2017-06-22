require 'rails_helper'

RSpec.describe Token, type: :model do
  describe 'indexes' do
    it { should have_db_index :user_id }
  end

  describe 'validations' do
    it { should belong_to :user }
    it { should validate_presence_of :user_id }

    it { should validate_presence_of :expires_at }
  end

  describe 'defaults' do
    it 'defaults to 30 days expiry' do
      time = Time.local(2017, 6, 22, 7, 30, 0)
      travel_to time do
        token = Token.new
        expect(token.expires_at).to eq time + 30.days
      end
    end
  end

  describe '#to_s' do
    it 'returns the ID' do
      token = FactoryGirl.build :token
      expect(token.to_s).to eq(token.id)
    end
  end
end
