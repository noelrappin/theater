class Ticket < ActiveRecord::Base

  belongs_to :user
  belongs_to :performance
  has_one :event, through: :performance

  enum status: [:unsold, :waiting]
  enum access: [:general]

  monetize :price_cents

  def waiting_for(user)
    self.status = :waiting
    self.user = user
  end

end
