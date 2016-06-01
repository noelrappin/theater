class Payment < ActiveRecord::Base

  include HasReference

  belongs_to :user
  has_many :payment_line_items
  has_many :references, through: :payment_line_items, source_type: "Ticket"
  belongs_to :administrator, class_name: "User"

  has_many :refunds, class_name: "Payment",
                     foreign_key: "original_payment_id"
  belongs_to :original_payment, class_name: "Payment"
  belongs_to :discount_code

  monetize :price_cents
  monetize :discount_cents

  STATUSES = %i(created succeeded pending failed refund_pending refunded).freeze

  enum status: STATUSES

  STATUSES.each do |status|
    define_method "make_#{status}" do
      self.status = status
    end
  end

  def total_cost
    tickets.map(&:price).sum
  end

  def sorted_ticket_ids
    tickets.map(&:id).sort
  end

  def generate_refund_payment(amount_cents:, admin:)
    refund_payment = Payment.create(
      user_id: user_id, price_cents: -amount_cents, status: "refund_pending",
      payment_method: payment_method, original_payment_id: id,
      administrator: admin, reference: Payment.generate_reference)
    payment_line_items.each do |line_item|
      line_item.generate_refund_payment(
        admin: admin,
        amount_cents: amount_cents,
        refund_payment: refund_payment)
    end
    refund_payment
  end

  def payment
    self
  end

  def maximum_available_refund
    price + refunds.map(&:price).sum
  end

  def can_refund?(price)
    price <= maximum_available_refund
  end

  def refund?
    price < 0
  end

end
