class ChargeSetupValidityException < StandardError

  def initialize(user:, expected_purchase_cents:, expected_ticket_ids:)
    @user = user
    @expected_purchase_cents = expected_purchase_cents
    @expected_ticket_ids = expected_ticket_ids
  end

end
