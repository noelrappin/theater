class PurchasesCart

  attr_accessor :user, :stripe_token, :purchase_amount, :success, :payment,
                :stripe_charge, :expected_ticket_ids, :payment_reference

  # START: purchase_cart_initialize
  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:, payment_reference: nil)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @payment_reference = payment_reference || Payment.generate_reference
  end
  # END: purchase_cart_initialize

  def run
    pre_charge
    charge
    post_charge
    @success = @continue
  end

  # START: pre_charge
  def pre_charge_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart.select do |ticket|
      ticket.payment_reference == payment_reference
    end
  end

  def existing_payment
    Payment.find_by(reference: payment_reference)
  end

  def pre_charge
    return true if existing_payment
    unless pre_charge_valid?
      @continue = false
      return
    end
    purchase_tickets
    create_payment
    @continue = save
  end
  # END: pre_charge

  def purchase_tickets
    tickets.each(&:purchase)
  end

  # START: create_payment
  def create_payment
    self.payment = existing_payment || Payment.new
    payment.assign_attributes(
      user_id: user.id, price_cents: purchase_amount.cents, status: "created",
      reference: payment_reference, payment_method: "stripe")
    tickets.each do |ticket|
      line_item = payment.payment_line_items.find_or_initialize_by(
        ticket_id: ticket.id)
      line_item.price_cents = ticket.price.cents
    end
  end
  # END: create_payment

  # START: save
  def save
    payment.transaction do
      payment.save!
      true
    end
  end
  # END: save

  # START: charge
  def charge
    return unless @continue
    return if payment.response_id.present?
    @stripe_charge = StripeCharge.new(token: stripe_token, payment: payment)
    @stripe_charge.charge
    payment.attributes = @stripe_charge.payment_attributes
    reverse_charge if payment.failed?
  end
  # END: charge

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
    @continue = save && payment.succeeded?
  end

end
