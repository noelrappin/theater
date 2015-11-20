FactoryGirl.define do
  factory :order do
    user nil
    price_cents 1
    status :successful
    reference "MyString"
    payment_method "MyString"
  end

end
