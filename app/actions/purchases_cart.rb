class PurchasesCart

  attr_accessor :user, :stripe_token, :purchase_amount, :success, :order

  def initialize(user:, stripe_token:, purchase_amount_cents:)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def run
    tickets.each(&:purchase)
    self.order = Order.new(
      user_id: user.id, price_cents: purchase_amount.cents,
      reference: Order.generate_reference, payment_method: "stripe")
    tickets.each do |ticket|
      order.order_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
    save
    charge = StripeCharge.charge(token: stripe_token, order: order)
    order.attributes = {status: charge.status, response_id: charge.id,
                        full_response: charge.to_json}
    @success = save && order.succeeded?
  end

  delegate :save, to: :order

end
