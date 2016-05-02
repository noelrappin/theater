FactoryGirl.define do
  factory :user do
    name "Test User"
    email { |n| "test_#{n}@example.com" }
    password "please123"

    trait :admin do
      role "admin"
    end

  end
end
