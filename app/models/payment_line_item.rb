class PaymentLineItem < ActiveRecord::Base

  belongs_to :payment
  belongs_to :ticket

  monetize :price_cents

end
