class PurchasesCartChargeJob < ActiveJob::Base

  include Rollbar::ActiveJob

  queue_as :default

  rescue_from(PreExistingPurchaseException) do |exception|
    Rollbar.error(exception)
  end

  def perform(payment, stripe_token)
    charge_action = StripePurchasesCartCharge.new(payment, stripe_token)
    charge_action.run
  end

end
