class CreatesPlan

  attr_accessor :remote_id, :plan_name, :price_cents, :interval,
                :tickets_allowed, :ticket_category, :plan

  def initialize(remote_id:, plan_name:, price_cents:, interval:,
                 tickets_allowed:, ticket_category:)
    @remote_id = remote_id
    @plan_name = plan_name
    @price_cents = price_cents
    @interval = interval
    @tickets_allowed = tickets_allowed
    @ticket_category = ticket_category
  end

  def remote_stripe_plan(remote_id)
    Stripe::Plan.retrieve(remote_id)
  end

  def run
    unless remote_stripe_plan
      Stripe::Plan.create(
        id: remote_id, amount: price_cents,
        currency: "usd", interval: interval, name: plan_name)
    end
    api = PayPal::SDK::REST::API.new
    paypal_remote_plan = PayPal::SDK::REST::Plan.new(name: plan_name,
      type: "fixed",
      token: api.token,
      description: plan_name,
      payment_definitions: [{
        name: "Regular Payments",
        type: "REGULAR",
        frequency_interval: "1",
        frequency: interval.upcase,
        cycles: 12,
        amount: {value: price_cents / 100, currency: "USD"},
        }],
      merchant_preferences: {
        cancel_url: "http://host/paypal/cancel",
        return_url: "http://host/paypal/return"
        })
    result = paypal_remote_plan.create
    patch = PayPal::SDK::REST::Patch.new
    patch.op = "replace"
    patch.path = "/"
    patch.value = {state: "ACTIVE"}
    update = paypal_remote_plan.update(patch)
    self.plan = Plan.create(
      remote_id: remote_plan.id, plan_name: plan_name,
      price_cents: price_cents, interval: interval,
      tickets_allowed: tickets_allowed,
      ticket_category: ticket_category, status: :active)
  end

end
