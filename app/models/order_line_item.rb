class OrderLineItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :ticket

  monetize :price_cents

end
