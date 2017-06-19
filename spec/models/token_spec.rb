require 'rails_helper'

RSpec.describe Token, type: :model do
  describe 'indexes' do
    it { should have_db_index :user_id }
  end

  describe 'validations' do
    it { should belong_to :user }
  end

  describe '#to_s' do
    it 'returns the ID' do
      token = FactoryGirl.build :token
      expect(token.to_s).to eq(token.id)
    end
  end
end
