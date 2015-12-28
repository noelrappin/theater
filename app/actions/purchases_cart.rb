class PurchasesCart

  attr_accessor :user, :stripe_token, :purchase_amount, :success, :order,
                :stripe_charge, :expected_ticket_ids, :order_reference

  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:, order_reference: nil)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @order_reference = order_reference || Order.generate_reference
  end

  def run
    pre_charge
    charge
    post_charge
    @success = @continue
  end

  def pre_charge_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def pre_charge
    unless pre_charge_valid?
      @continue = false
      return
    end
    purchase_tickets
    create_order
    @continue = save
  end

  def purchase_tickets
    tickets.each(&:purchase)
  end

  def create_order
    self.order = Order.new(
      user_id: user.id, price_cents: purchase_amount.cents, status: "created",
      reference: order_reference, payment_method: "stripe")
    tickets.each do |ticket|
      order.order_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
  end

  def save
    Order.transaction do
      order.save
    end
  end

  def charge
    return unless @continue
    @stripe_charge = StripeCharge.new(token: stripe_token, order: order)
    @stripe_charge.charge
    order.attributes = @stripe_charge.order_attributes
    reverse_charge if order.failed?
  end

  def unpurchase_tickets
    tickets.each(&:return_to_cart)
  end

  def reverse_charge
    unpurchase_tickets
    save
    @continue = false
  end

  def post_charge
    return unless @continue
    @continue = save && order.succeeded?
  end

end
