FactoryGirl.define do
  factory :order_line_item do
    transaction nil
    ticket nil
    price_cents 1
  end

end
