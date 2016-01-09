FactoryGirl.define do
  factory :payment_line_item do
    transaction nil
    ticket nil
    price_cents 1
  end

end
