FactoryGirl.define do
  factory :bird do
    common_name     { Faker::Name.first_name }
    scientific_name { Faker::Name.unique.name }
    sort_order { Faker::Number.unique.number(3) }

    trait :invalid do
      common_name nil
    end
  end
end
