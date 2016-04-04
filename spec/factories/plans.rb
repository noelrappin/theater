FactoryGirl.define do
  factory :plan do
    plan_name "Subscription plan"
    price_cents 10_000
    interval :month
    tickets_allowed 2
    ticket_category :member
  end

end
