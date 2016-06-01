FactoryGirl.define do
  factory :discount_code do
    code "CODE"
    percentage 25
    description "MyText"
    min_amount_cents nil
    max_discount_cents nil
    max_uses nil
  end
end
