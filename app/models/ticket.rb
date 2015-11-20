class Ticket < ActiveRecord::Base

  belongs_to :user
  belongs_to :performance
  has_one :event, through: :performance

  enum status: [:unsold, :waiting, :purchased]
  enum access: [:general]

  monetize :price_cents

  def place_in_cart_for(user)
    update(status: :waiting, user: user)
  end

  def purchase
    update(status: :purchased)
  end

end
