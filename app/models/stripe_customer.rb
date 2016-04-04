class StripeCustomer

  def self.create(token:, plan:, email:)
    remote_customer = Stripe::Customer.create(
      source: token&.id, plan: plan&.remote_id, email: email)
    StripeCustomer.new(remote_customer: remote_customer)
  end

  def initialize(id: nil, remote_customer: nil)
    @id = id
    @remote_customer = remote_customer
  end

  def id
    @id ||= remote_customer.id
  end

  def remote_customer
    @remote_customer ||= Stripe::Customer.retrieve(id)
  end

  delegate :subscriptions, to: :remote_customer

  def find_subscription_for(plan)
    subscriptions.find { |s| s.plan.id == plan.remote_id }
  end

end
