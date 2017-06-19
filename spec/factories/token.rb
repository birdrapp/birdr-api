FactoryGirl.define do
  factory :token do
    id "07630030-a00d-4d0a-a360-efccaf95a172"
    association :user, factory: :user
  end
end
