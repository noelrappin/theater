class StripePurchasesCartSetup < AbstractPurchasesCart

  attr_accessor :stripe_token, :stripe_charge

  def initialize(user:, stripe_token:, purchase_amount_cents:,
                 expected_ticket_ids:, payment_reference: nil)
    super(user: user, purchase_amount_cents: purchase_amount_cents,
          expected_ticket_ids: expected_ticket_ids,
          payment_reference: payment_reference)
    @stripe_token = stripe_token
  end

  def update_tickets
    tickets.each(&:make_purchased)
  end

  def on_success
    PurchasesCartChargeJob.perform_later(payment, stripe_token.id)
    calculate_success
  end

  def unpurchase_tickets
    tickets.each(&:return_to_cart)
  end

  def purchase_attributes
    super.merge(payment_method: "stripe")
  end

end
