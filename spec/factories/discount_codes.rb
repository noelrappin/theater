FactoryGirl.define do
  factory :discount_code do
    code "MyString"
    percentage 1
    description "MyText"
    min_amount_cents 1
    max_discount_cents 1
    max_uses 1
  end
end
