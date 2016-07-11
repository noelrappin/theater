class StripeCreatesSubscription

  attr_accessor :user, :expected_subscription_id, :token, :success

  def initialize(user:, expected_subscription_id:, token:)
    @user = user
    @expected_subscription_id = expected_subscription_id
    @token = token
    @successs = false
  end

  def subscription
    @subscription ||= user.subscriptions_in_cart.first
  end

  def expected_plan_valid?
    expected_subscription_id.first.to_i == subscription.id.to_i
  end

  def run
    return unless expected_plan_valid?
    stripe_customer = StripeCustomer.new(user: user)
    return unless stripe_customer.valid?
    stripe_customer.source = token
    subscription.make_stripe_payment(stripe_customer)
    stripe_customer.add_subscription(subscription)
    @success = save
  rescue Stripe::StripeError => exception
    Rollbar.error(exception)
  end

  def save
    Subscription.transaction do
      subscription.save! && user.save!
    end
  end

  def redirect_on_success_url
    user
  end

end
