class PurchasesCartChargeJob < ActiveJob::Base

  include Rollbar::ActiveJob

  queue_as :default

  rescue_from(PreExistingOrderException) do |exception|
    Rollbar.error(exception)
  end

  def perform(order, stripe_token)
    charge_action = PurchasesCartCharge.new(order, stripe_token)
    charge_action.run
  end

end
