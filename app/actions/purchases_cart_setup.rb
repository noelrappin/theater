class PurchasesCartSetup

  attr_accessor :user, :stripe_token, :purchase_amount, :order,
                :stripe_charge, :expected_ticket_ids, :order_reference

  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:, order_reference: nil)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @order_reference = order_reference || Order.generate_reference
    @order = existing_order || Order.new
  end

  def existing_order
    Order.find_by(reference: order_reference)
  end

  def run
    return if existing_order
    return unless pre_charge_valid?
    purchase_tickets
    create_order
    save
    on_success
  end

  def on_success
    PurchasesCartChargeJob.perform_later(order, stripe_token)
  end

  def pre_charge_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def purchase_tickets
    tickets.each(&:purchase)
  end

  def create_order
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
    order.save!
  end

end
