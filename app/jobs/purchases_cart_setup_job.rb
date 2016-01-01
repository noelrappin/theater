class PurchasesCartChargeJob < ActiveJob::Base

  queue_as :default

  def perform(order)
    charge_action = PurchasesCartCharge.new(order)
    charge_action.run
  end

end
