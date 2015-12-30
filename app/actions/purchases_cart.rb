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

  def existing_order
    Order.find_by(reference: order_reference)
  end

  def pre_charge
    return true if existing_order
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
    self.order = existing_order || Order.new
    order.assign_attributes(
      user_id: user.id, price_cents: purchase_amount.cents, status: "created",
      reference: order_reference, payment_method: "stripe")
    tickets.each do |ticket|
      line_item = order.order_line_items.find_or_initialize_by(
        ticket_id: ticket.id)
      line_item.price_cents = ticket.price.cents
    end
  end

  def save
    Order.transaction do
      order.save
    end
  end

  def charge
    return unless @continue
    return if order.response_id.present?
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
