class Subscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :plan

  STATUSES = %i(active inactive waiting pending_initial_payment).freeze

  delegate :plan_name, to: :plan

  enum status: STATUSES

  STATUSES.each do |status|
    define_method "make_#{status}" do
      self.status = status
    end
  end

  def make_stripe_payment(stripe_customer)
    make_pending_initial_payment
    self.payment_method = :stripe
    self.remote_id = stripe_customer.find_subscription_for(plan)
  end

  def remote_plan_id
    plan.remote_id
  end

end