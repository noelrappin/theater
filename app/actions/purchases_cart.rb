class PurchasesCart

<<<<<<< HEAD
  attr_accessor :user, :stripe_token, :purchase_amount, :success, :order,
                :stripe_charge
=======
  attr_accessor :user, :stripe_token, :purchase_amount, :success, :payment
>>>>>>> server_charge_01

  def initialize(user:, stripe_token:, purchase_amount_cents:)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def run
    purchase_tickets
    create_payment
    save
    charge
    @success = save && payment.succeeded?
  end

  def purchase_tickets
    tickets.each(&:purchase)
  end

  def create_payment
    self.payment = Payment.new(
      user_id: user.id, price_cents: purchase_amount.cents, status: "created",
      reference: Payment.generate_reference, payment_method: "stripe")
    tickets.each do |ticket|
      payment.payment_line_items.build(
        ticket_id: ticket.id, price_cents: ticket.price.cents)
    end
  end

  ## START: code.purchase_charge
  def charge
    @stripe_charge = StripeCharge.charge(token: stripe_token, payment: payment)
    payment.attributes = {
      status: @stripe_charge.status,
      response_id: @stripe_charge.id,
      full_response: @stripe_charge.to_json}
  end
  ## END: code.purchase_charge

  delegate :save, to: :payment

end
