class CreatesPlan

  attr_accessor :remote_id, :plan_name, :amount_cents, :interval,
                :tickets_allowed, :ticket_category, :plan

  def initialize(remote_id:, plan_name:, amount_cents:, interval:,
                 tickets_allowed:, ticket_category:)
    @remote_id = remote_id
    @plan_name = plan_name
    @amount_cents = amount_cents
    @interval = interval
    @tickets_allowed = tickets_allowed
    @ticket_category = ticket_category
  end

  def run
    remote_plan = Stripe::Plan.create(
      id: remote_id, amount: amount_cents,
      currency: "usd", interval: interval, name: plan_name)
    self.plan = Plan.create(remote_id: remote_plan.id, plan_name: plan_name,
                            amount_cents: amount_cents, interval: interval,
                            tickets_allowed: tickets_allowed,
                            ticket_category: ticket_category)
  end

end
