FactoryGirl.define do
  factory :payment do
    user nil
    price_cents 1
    status :created
    reference "MyString"
    payment_method "MyString"
  end

end
