FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password_reset_token { Faker::Crypto.md5 }
    password_reset_sent_at { Time.now }
    password { Faker::Lorem.characters(6) }

    trait :invalid_email do
      email 'invalid.com'
    end
  end
end
