class PayPalPurchasesCart < AbstractPurchasesCart

  attr_accessor :pay_pal_payment

  def update_tickets
    tickets.each(&:make_pending)
  end

  def redirect_on_success_url
    pay_pal_payment.redirect_url
  end

  delegate :save, to: :payment

  def purchase_attributes
    super.merge(payment_method: "paypal")
  end

  def purchase
    @pay_pal_payment = PayPalPayment.new(payment: payment)
    payment.response_id = pay_pal_payment.response_id
  end

end
