class ExecutesPayPalPayment

  attr_accessor :payment_id, :token, :payer_id, :payment, :success

  def initialize(payment_id:, token:, payer_id:)
    @payment_id = payment_id
    @token = token
    @payer_id = payer_id
    @success = false
    @continue = true
  end

  def payment
    @payment ||= Payment.find_by(
      payment_method: "paypal", response_id: payment_id)
  end

  def pay_pal_payment
    @pay_pal_payment ||= PayPalPayment.find(payment_id, payment: payment)
  end

  def pre_purchase
    @continue = pay_pal_payment.match?
  end

  def run
    pre_purchase
    purchase
    post_purchase
  end

  def purchase
    return unless @continue
    @continue = pay_pal_payment.execute(payer_id: payer_id)
  end

  def post_purchase
    if @continue
      payment.references.each(&:make_purchased)
      payment.make_succeeded
      self.success = save
    else
      payment.references.each(&:return_to_cart)
      payment.make_failed
      save
    end
  end

  def save
    Payment.transaction do
      payment.references.each(&:save)
      payment.save
    end
  end

end
