class Ticket < ActiveRecord::Base

  include HasReference

  belongs_to :user
  belongs_to :performance
  has_one :event, through: :performance

  STATUSES = %i(unsold waiting purchased pending refund_pending refunded).freeze

  enum status: STATUSES
  enum access: [:general]

  monetize :price_cents

  def place_in_cart_for(user)
    update(status: :waiting, user: user)
  end

  STATUSES.each do |status|
    define_method "make_#{status}" do
      self.status = status
    end
  end

  def return_to_cart
    self.status = :waiting
  end

  def return_to_cart!
    return_to_cart
    save
  end

  def refund_successful
    refunded!
    new_ticket = dup
    new_ticket.unsold!
  end

end
