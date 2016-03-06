## START: purchases_cart_init
class AbstractPurchasesCart

  attr_accessor :user, :purchase_amount_cents, :purchase_amount, :success,
                :payment, :expected_ticket_ids, :payment_reference

  def initialize(user: nil, purchase_amount_cents: nil, expected_ticket_ids: "",
                 payment_reference: nil)
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
    @payment_reference = payment_reference || Payment.generate_reference
  end
  ## END: purchases_cart_init

  def run
    pre_purchase
    purchase
    post_purchase
    @success = @continue
  end

  def calculate_success
    @success = save && payment.succeeded?
  end

  def pre_purchase_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  ## START: purchases_pre_purchase
  def tickets
    @tickets ||= @user.tickets_in_cart.select do |ticket|
      ticket.payment_reference == payment_reference
    end
  end

  def existing_payment
    Payment.find_by(reference: payment_reference)
  end

  def pre_purchase
    return true if existing_payment
    unless pre_purchase_valid?
      @continue = false
      return
    end
    update_tickets
    create_payment
    @continue = save
  end
  ## END: purchases_pre_purchase

  def redirect_on_success_url
    nil
  end

  def create_payment
    self.payment = existing_payment || Payment.new
    payment.assign_attributes(purchase_attributes)
    tickets.each do |ticket|
      payment.payment_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
  end

  # START: save
  def save
    payment.transaction do
      payment.save!
      true
    end
  end
  # END: save

  def purchase_attributes
    {user_id: user.id, price_cents: purchase_amount.cents, status: "created",
     reference: Payment.generate_reference}
  end

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
  ## END: purchases_charge

  ## START: purchases_post_charge
  def post_purchase
    return unless @continue
    @continue = save && calculate_success
  end
  ## END: purchases_post_charge

end
