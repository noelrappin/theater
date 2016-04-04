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

  def plan_id
    subscription.plan.remote_id
  end

  def run
    stripe_customer = user.attach_to_stripe(
      token: token, plan: subscription.plan)
    subscription.make_stripe_payment(stripe_customer)
    @success = save
  end

  def save
    Subscription.transaction do
      subscription.save && user.save
    end
  end

  def redirect_on_success_url
    user
  end

end
