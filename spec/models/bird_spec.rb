require 'rails_helper'

RSpec.describe Bird, type: :model do
  describe "indexes" do
    it { should have_db_index(:scientific_name).unique(true) }
    it { should have_db_index(:sort_order).unique(true) }
  end

    describe 'relationships' do
    it { should have_many(:sightings).dependent(:destroy) }
  end

  describe "validations" do
    subject { FactoryGirl.build :bird }

    it { should validate_presence_of :common_name }
    it { should validate_length_of(:common_name).is_at_most(255) }

    it { should validate_presence_of :scientific_name }
    it { should validate_length_of(:scientific_name).is_at_most(255) }
    it { should validate_uniqueness_of(:scientific_name).case_insensitive }
  end
end
