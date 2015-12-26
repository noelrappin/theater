## START: purchases_cart_init
class PurchasesCart

  attr_accessor :user, :stripe_token, :purchase_amount, :success, :order,
                :stripe_charge, :expected_ticket_ids

  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
  end

  def run
    pre_charge
    charge
    post_charge
    @success = @continue
  end
  ## START: purchases_cart_init

  ## START: purchases_pre_charge
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
      reference: Order.generate_reference, payment_method: "stripe")
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
  ## END: purchases_pre_charge

  ## START: purchases_charge
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
  ## END: purchases_charge

  ## START: purchases_post_charge
  def post_charge
    return unless @continue
    @continue = save && order.succeeded?
  end
  ## END: purchases_post_charge

end
