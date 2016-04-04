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

  def run
    remote_plan = Stripe::Plan.create(
      id: remote_id, amount: price_cents,
      currency: "usd", interval: interval, name: plan_name)
    self.plan = Plan.create(
      remote_id: remote_plan.id, plan_name: plan_name,
      price_cents: price_cents, interval: interval,
      tickets_allowed: tickets_allowed,
      ticket_category: ticket_category, status: :active)
  end

end
