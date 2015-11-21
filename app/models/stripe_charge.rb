class StripeCharge

  attr_accessor :token, :order, :response

  def self.charge(token:, order:)
    StripeCharge.new(token: token, order: order).charge
  end

  def initialize(token:, order: )
    @token = token
    @order = order
  end

  def charge
    return if response.present?
    @response = Stripe::Charge.create({
      amount: order.price.cents, currency: "usd", source: token.id,
      description: "", metadata: {reference: order.reference}},
      {idempotency_key: order.reference})
  end

end
