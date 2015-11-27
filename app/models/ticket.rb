class Ticket < ActiveRecord::Base

  include HasReference

  belongs_to :user
  belongs_to :performance
  has_one :event, through: :performance

  enum status: [:unsold, :waiting, :purchased]
  enum access: [:general]

  monetize :price_cents

  def place_in_cart_for(user)
    update(status: :waiting, user: user)
  end

  ## START: code.purchase
  def purchase
    self.status = :purchased
  end

  def purchase!
    purchase
    save
  end
  ## END: code.purchase

end
