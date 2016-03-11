class PurchasesCartChargeJob < ActiveJob::Base

  queue_as :default

  def perform(payment, stripe_token)
    charge_action = StripePurchasesCartCharge.new(payment, stripe_token)
    charge_action.run
  end

end
