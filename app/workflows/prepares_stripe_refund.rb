class PreparesStripeRefund

  attr_accessor :user, :administrator, :refund_amount_cents, :payment_id,
                :success, :refund_payment, :refundable

  delegate :save, to: :refund_payment

  def initialize(user:, administrator:, refund_amount_cents:, refundable:)
    @user = user
    @administrator = administrator
    @refund_amount_cents = refund_amount_cents
    @refundable = refundable
    @success = false
  end

  def pre_purchase_valid?
    refundable.present?
  end

  def run
    Payment.transaction do
      raise "not valid" unless pre_purchase_valid?
      self.success = true
      self.refund_payment = generate_refund_payment.payment
      raise "can't refund that amount" unless
        refund_payment.can_refund?(refund_amount_cents)
      update_tickets
      save
      RefundChargeJob.perform_later(refundable_id: refund_payment.id)
    end
  rescue StandardError
    on_failure
  end

  def on_failure
    self.success = false
  end

  def generate_refund_payment
    refundable.generate_refund_payment(
      amount_cents: refund_amount_cents, admin: administrator)
  end

  def update_tickets
    refundable.references.each do |ticket|
      ticket.status = "refund_pending"
    end
  end

  def success?
    success
  end

end
