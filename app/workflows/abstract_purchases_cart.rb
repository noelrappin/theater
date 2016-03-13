## START: purchases_cart_init
class AbstractPurchasesCart

  attr_accessor :user, :purchase_amount_cents, :purchase_amount, :success,
                :payment, :expected_ticket_ids

  def initialize(user: nil, purchase_amount_cents: nil, expected_ticket_ids: "")
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
  end

  def run
    pre_purchase
    purchase
    post_purchase
    @success = @continue
  end
  ## END: purchases_cart_init

  def calculate_success
    @success = save && payment.succeeded?
  end

  ## START: purchases_pre_purchase
  def pre_purchase_valid?
    purchase_amount == tickets.map(&:price).sum &&
      expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def pre_purchase
    unless pre_purchase_valid?
      @continue = false
      return
    end
    update_tickets
    create_payment
    @continue = save
  end

  def redirect_on_success_url
    nil
  end

  def create_payment
    self.payment = Payment.new(purchase_attributes)
    tickets.each do |ticket|
      payment.payment_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
  end

  def save
    payment.transaction do
      payment.save
    end
  end
  ## END: purchases_pre_purchase

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

  ## START: purchases_post_charge
  def post_purchase
    return unless @continue
    @continue = save && calculate_success
  end
  ## END: purchases_post_charge

end
