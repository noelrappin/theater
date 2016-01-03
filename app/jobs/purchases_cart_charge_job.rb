class PurchasesCartChargeJob < ActiveJob::Base
  include Rollbar::ActiveJob

  queue_as :default

  def perform(order, stripe_token)
    charge_action = PurchasesCartCharge.new(order, stripe_token)
    charge_action.run
  end

end
