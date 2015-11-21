FactoryGirl.define do
  factory :order do
    user nil
    price_cents 1
    status :created
    reference "MyString"
    payment_method "MyString"
  end

end
