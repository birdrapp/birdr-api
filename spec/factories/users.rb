FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password_reset_token { Faker::Crypto.md5 }
    password_reset_digest { cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost; BCrypt::Password.create(password_reset_token, cost: cost) }
    password_reset_sent_at { Time.now }
    password { Faker::Lorem.characters(6) }

    trait :invalid_email do
      email 'invalid.com'
    end

    trait :expired_password_reset do
      password_reset_sent_at { Time.now - 1.day }
    end
  end
end
