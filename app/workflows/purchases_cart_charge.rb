class PurchasesCartCharge

  attr_accessor :payment, :stripe_token, :stripe_charge

  def initialize(payment, stripe_token)
    @payment = payment
    @stripe_token = StripeToken.new(stripe_token: stripe_token)
  end

  def run
    result = charge
    result ? on_success : on_failure
  end

  def charge
    return if payment.response_id.present?
    @stripe_charge = StripeCharge.new(token: stripe_token, payment: payment)
    @stripe_charge.charge
    payment.attributes = @stripe_charge.payment_attributes
    payment.succeeded?
  end

  def unpurchase_tickets
    payment.tickets.each(&:return_to_cart)
  end

  def on_success
    save
  end

  def on_failure
    unpurchase_tickets
    save
  end

  def save
    payment.save!
  end

end
