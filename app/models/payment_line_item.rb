class PaymentLineItem < ActiveRecord::Base

  belongs_to :payment
  belongs_to :ticket
  has_one :performance, through: :ticket
  has_one :event, through: :performance

  delegate :name, to: :performance, allow_nil: true
  delegate :id, to: :event, prefix: true, allow_nil: true

  monetize :price_cents

end
