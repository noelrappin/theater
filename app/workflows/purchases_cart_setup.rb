class PurchasesCartSetup

  attr_accessor :user, :stripe_token, :purchase_amount, :payment,
                :stripe_charge, :expected_ticket_ids, :payment_reference

  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:, payment_reference: nil)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @payment_reference = payment_reference || Payment.generate_reference
    @payment = existing_payment || Payment.new
  end

  # START: run_with_exception
  def run
    raise PreExistingPurchaseException.new(purchase) if existing_payment
    raise ChargeSetupValidityException.new(
      user: user,
      expected_purchase_cents: purchase_amount.to_i,
      expected_ticket_ids: expected_ticket_ids) unless pre_charge_valid?
    purchase_tickets
    create_payment
    save
    on_success
  end
  # END: run_with_exception

  def on_success
    PurchasesCartChargeJob.perform_later(payment, stripe_token)
  end

  def pre_charge_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart.select do |ticket|
      ticket.payment_reference == payment_reference
    end
  end

  # START: pre_charge
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

  def create_payment
    payment.assign_attributes(
      user_id: user.id, price_cents: purchase_amount.cents, status: "created",
      reference: payment_reference, payment_method: "stripe")
    tickets.each do |ticket|
      line_item = payment.payment_line_items.find_or_initialize_by(
        ticket_id: ticket.id)
      line_item.price_cents = ticket.price.cents
    end
  end

  def save
    payment.save!
  end

end
