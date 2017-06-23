require 'rails_helper'

RSpec.describe Sighting, type: :model do
  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:bird) }
  end

  describe "indexes" do
    it { should have_db_index(:bird_id) }
    it { should have_db_index(:user_id) }
    it { should have_db_index([:user_id, :bird_id]).unique(true) }
  end

  describe "validations" do
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :bird_id }
  end
end
