class CashPurchasesCart < AbstractPurchasesCart

  def update_tickets
    tickets.each(&:make_purchased)
  end

  def on_success
    @success = save
  end

  def purchase_attributes
    super.merge(payment_method: "cash", status: "succeeded",
                administrator_id: user.id)
  end

  def validity_check
    raise UnauthorizedPurchaseException.new(user: user) unless user.admin?
    super
  end

  def save
    return unless user.admin?
    Payment.transaction do
      payment.save!
      true
    end
  end

end
