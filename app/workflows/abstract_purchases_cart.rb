class AbstractPurchasesCart

  attr_accessor :user, :purchase_amount_cents, :purchase_amount, :success,
                :payment, :expected_ticket_ids, :payment_reference,
                :discount_code_string

  def initialize(user: nil, purchase_amount_cents: nil,
                 expected_ticket_ids: "", payment_reference: nil,
                 discount_code_string: nil)
    @user = user
    @discount_code_string = discount_code_string
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @payment_reference = payment_reference || Payment.generate_reference
  end

  def discount_code
    @discount_code ||= DiscountCode.find_by(code: discount_code_string)
  end

  def price_calculator
    @price_calculator ||= PriceCalculator.new(tickets, discount_code)
  end

  delegate :total_price, to: :price_calculator

  def calculate_success
    @success = save && payment.succeeded?
  end

  # START: admin_valid
  def amount_valid?
    return true if user.admin?
    purchase_amount == total_price
  end

  def tickets_valid?
    expected_ticket_ids == tickets.map(&:id).sort
  end

  def pre_purchase_valid?
    amount_valid? && tickets_valid?
  end
  # END: admin_valid

  def tickets
    @tickets ||= @user.tickets_in_cart.select do |ticket|
      ticket.payment_reference == payment_reference
    end
  end

  def existing_payment
    Payment.find_by(reference: payment_reference)
  end

  def validity_check
    raise PreExistingPurchaseException.new(purchase) if existing_payment
    raise ChargeSetupValidityException.new(
      user: user,
      expected_purchase_cents: purchase_amount.to_i,
      expected_ticket_ids: expected_ticket_ids) unless pre_purchase_valid?
  end

  def run
    validity_check
    update_tickets
    create_payment
    save
    on_success
  rescue
    on_failure
    raise
  end

  def on_failure
    unpurchase_tickets
    save
  end

  def redirect_on_success_url
    nil
  end

  def create_payment
    self.payment = existing_payment || Payment.new
    payment.assign_attributes(purchase_attributes)
    tickets.each do |ticket|
      payment.payment_line_items.build(
        reference_id: ticket.id, price_cents: ticket.price.cents,
        reference_type: "Ticket")
    end
  end

  def save
    Payment.transaction do
      payment.save!
      true
    end
  end

  # START: code_purchase_attributes
  def purchase_attributes
    {user_id: user.id, price_cents: purchase_amount.cents,
     status: "created", reference: Payment.generate_reference,
     discount_code_id: discount_code&.id,
     discount: price_calculator.discount}
  end
  # END: code_purchase_attributes

  def success?
    success
  end

  def unpurchase_tickets
    tickets.each(&:return_to_cart)
  end

  def reverse_purchase
    unpurchase_tickets
    save
    @continue = false
  end

  def post_purchase
    return unless @continue
    @continue = save && calculate_success
  end

end
