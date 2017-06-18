require 'rails_helper'

RSpec.describe User, type: :model do
  let (:user) { User.new first_name: 'Matt', last_name: 'Williams', email: 'matt@williams.com', password: 'secret' }

  describe "#first_name" do
    it "is required" do
      user.first_name = ''
      expect(user.valid?).to be false
    end

    it 'cannot be longer than 255 characters' do
      user.first_name = 'm' * 256
      expect(user.valid?).to be false
    end
  end

  describe '#last_name' do
    it 'is required' do
      user.last_name = ''
      expect(user.valid?).to be false
    end

    it 'cannot be longer than 255 characters' do
      user.last_name = 'w' * 300
      expect(user.valid?).to be false
    end
  end

  describe '#email' do
    it 'is required' do
      user.email = ''
      expect(user.valid?).to be false
    end

    it 'cannot be longer than 255 characters' do
      user.email = 'w' * 300
      expect(user.valid?).to be false
    end

    it 'must match an email address pattern' do
      user.email = 'invalid.com'
      expect(user.valid?).to be false
    end

    it 'must be unique' do
      duplicate_user = user.dup
      duplicate_user.email = user.email.upcase
      user.save
      expect(duplicate_user.valid?).to be false
    end

    it 'should save a downcased email address' do
      mixed_case_email = 'ShOuT@mE.CoM'
      user.email = mixed_case_email
      user.save
      assert_equal mixed_case_email.downcase, user.reload.email
    end
  end

  describe '#password' do
    it 'should be present (nonblank)' do
      user.password = ' ' * 6
      expect(user.valid?).to be false
    end

    it 'should have minimum length of 6' do
      user.password = '123'
      expect(user.valid?).to be false
    end

    it 'creates a hash on save' do
      user.save
      expect(user.password_digest).to_not be nil
      expect(user.password).to_not be nil
      expect(user.password).to_not eq(user.password_digest)
    end
  end
end
