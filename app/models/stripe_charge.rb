class StripeCharge

  attr_accessor :token, :order, :response, :error

  def self.charge(token:, order:)
    StripeCharge.new(token: token, order: order).charge
  end

  def initialize(token:, order:)
    @token = token
    @order = order
  end

  def success?
    response || !error
  end

  def charge
    return if response.present?
    @response = Stripe::Charge.create(
      {amount: order.price.cents, currency: "usd", source: token.id,
       description: "", metadata: {reference: order.reference}},
      idempotency_key: order.reference)
  rescue Stripe::CardError => e
    @response = nil
    @error = e
  end

  def order_attributes
    success? ? success_attributes : failure_attributes
  end

  def success_attributes
    {status: response.status,
     response_id: response.id, full_response: response.to_json}
  end

  def failure_attributes
    {status: :failed, full_response: error.to_json}
  end

end
