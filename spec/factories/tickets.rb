FactoryGirl.define do
  factory :ticket do
    user nil
    performance nil
    status :unsold
    access :general
    price_cents 1
  end

end
