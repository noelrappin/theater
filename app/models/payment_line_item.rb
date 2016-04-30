class PaymentLineItem < ActiveRecord::Base

  belongs_to :payment
  belongs_to :reference, polymorphic: true

  delegate :name, :event, to: :performance, allow_nil: true
  delegate :id, to: :event, prefix: true, allow_nil: true
  delegate :performance, to: :reference, allow_nil: true

  monetize :price_cents

end
