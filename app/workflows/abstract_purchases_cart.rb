class AbstractPurchasesCart

  attr_accessor :user, :purchase_amount_cents, :purchase_amount, :success,
                :payment

  def initialize(user: nil, purchase_amount_cents: nil)
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def run
    update_tickets
    create_payment
    save
    purchase
    @success = save && payment.succeeded?
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def success_redirect
    nil
  end

  delegate :save, to: :payment

  def create_payment
    self.payment = Payment.new(purchase_attributes)
    tickets.each do |ticket|
      payment.payment_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
  end

  def purchase_attributes
    {user_id: user.id, price_cents: purchase_amount.cents, status: "created",
     reference: Payment.generate_reference}
  end

end
