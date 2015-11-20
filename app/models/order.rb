class Order < ActiveRecord::Base

  belongs_to :user
  has_many :order_line_items
  has_many :tickets, through: :transaction_line_items

  enum status: [:successful]

  def self.generate_reference
    loop do
      result = SecureRandom.hex(10)
      return result unless Order.exists?(reference: result)
    end
  end

end
