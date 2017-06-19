FactoryGirl.define do
  factory :user do
    first_name "Matt"
    last_name "Williams"
    email "matt@williams.com"
    password "secret"

    trait :invalid_email do
      email 'invalid.com'
    end
  end
end
