class PurchasesCartCharge

  attr_accessor :user, :stripe_token, :purchase_amount, :success, :order,
                :stripe_charge, :expected_ticket_ids, :order_reference

  def initialize(order)
    @order = order
  end

  def run
    result = charge
    result ? on_success : on_failure
  end

  def charge
    return if order.response_id.present?
    @stripe_charge = StripeCharge.new(token: stripe_token, order: order)
    @stripe_charge.charge
    order.attributes = @stripe_charge.order_attributes
    order.succeeded?
  end

  def unpurchase_tickets
    tickets.each(&:return_to_cart)
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

  def save
    Order.transaction do
      order.save!
    end
  end

end
