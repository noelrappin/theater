class ExecutesPayPalPayment

  attr_accessor :payment_id, :token, :payer_id, :payment, :success

  def initialize(payment_id:, token:, payer_id:)
    @payment_id = payment_id
    @token = token
    @payer_id = payer_id
    @success = false
  end

  def find_payment
    Payment.find_by(payment_method: "paypal", response_id: payment_id)
  end

  def pay_pal_payment
    @pay_pal_payment ||= PayPalPayment.find(payment_id)
  end

  def run
    @payment = find_payment
    execute_ok = pay_pal_payment.execute(payer_id: payer_id)
    return unless execute_ok
    payment.tickets.each(&:make_purchased)
    payment.make_succeeded
    save
    self.success = true
  end

  def save
    Payment.transaction do
      payment.tickets.each(&:save)
      payment.save
    end
  end

end
