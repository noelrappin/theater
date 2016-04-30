class PaymentLineItem < ActiveRecord::Base

  belongs_to :payment
  belongs_to :reference, polymorphic: true

  delegate :name, to: :performance, allow_nil: true
  delegate :id, to: :event, prefix: true, allow_nil: true

  monetize :price_cents

  def performance
    ap self
    reference&.performance
  end

  def event
    performance&.event
  end

end
