class PurchasesCartCharge

  attr_accessor :order, :stripe_token, :stripe_charge

  def initialize(order, stripe_token)
    @order = order
    @stripe_token = StripeToken.new(stripe_token: stripe_token)
  end

  def run
    result = charge
    result ? on_success : on_failure
  end

  def charge
    raise PreExistingOrderException(order) if order.response_id.present?
    @stripe_charge = StripeCharge.new(token: stripe_token, order: order)
    @stripe_charge.charge
    order.attributes = @stripe_charge.order_attributes
    order.succeeded?
  end

  def on_success
    save
    OrderMailer.notifiy_success(order).deliver_later
  end

  def on_failure
    unpurchase_tickets
    save
    OrderMailer.notifiy_failure(order).deliver_later
  end

  def unpurchase_tickets
    order.tickets.each(&:return_to_cart)
  end

  def save
    order.save!
  end

end
