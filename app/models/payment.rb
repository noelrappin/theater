class Payment < ActiveRecord::Base

  include HasReference

  belongs_to :user
  has_many :payment_line_items
  has_many :tickets, through: :payment_line_items

  monetize :price_cents

  STATUSES = %i(created succeeded pending failed).freeze

  enum status: STATUSES

  STATUSES.each do |status|
    define_method "make_#{status}" do
      self.status = status
    end
  end

  def total_cost
    tickets.map(&:price).sum
  end

end
