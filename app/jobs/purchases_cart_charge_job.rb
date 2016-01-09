class PurchasesCartChargeJob < ActiveJob::Base

  include Rollbar::ActiveJob

  queue_as :default

  rescue_from(PreExistingPurchaseException) do |exception|
    Rollbar.error(exception)
  end

  def perform(_order, stripe_token)
    charge_action = PurchasesCartCharge.new(purchase, stripe_token)
    charge_action.run
  end

end
