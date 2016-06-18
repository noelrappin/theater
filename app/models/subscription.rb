class Subscription < ActiveRecord::Base

  has_paper_trail

  belongs_to :user
  belongs_to :plan

  STATUSES = %i(active inactive waiting pending_initial_payment canceled).freeze

  delegate :plan_name, to: :plan

  enum status: STATUSES

  STATUSES.each do |status|
    define_method "make_#{status}" do
      self.status = status
    end
  end

  # START: make_stripe_payment
  def make_stripe_payment(stripe_customer)
    make_pending_initial_payment
    self.payment_method = :stripe
    self.remote_id = stripe_customer.find_subscription_for(plan)
  end
  # END: make_stripe_payment

  def remote_plan_id
    plan.remote_id
  end

  def update_end_date
    self.end_date = plan.end_date_from
  end

  # START: currently_active
  def currently_active?
    active? && (end_date > Time.zone.today)
  end
  # END: currently_active

end
