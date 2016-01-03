class ChargeSetupValidityException < StandardError

  def initialize(message=nil,
    user:, expected_purchase_cents:, expected_ticket_ids:)
    super(message)
    @user = user
    @expected_purchase_cents = expected_purchase_cents
    @expected_ticket_ids = expected_ticket_ids
  end

end
