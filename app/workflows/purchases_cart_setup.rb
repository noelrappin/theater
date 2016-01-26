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

  def existing_payment
    Payment.find_by(reference: payment_reference)
  end

  def run
    return if existing_payment
    return unless pre_charge_valid?
    purchase_tickets
    create_payment
    save
    on_success
  end

  def on_success
    PurchasesCartChargeJob.perform_later(payment, stripe_token)
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
