class DiscountCode < ActiveRecord::Base

  has_paper_trail

  monetize :min_amount_cents
  monetize :max_discount_cents

  def percentage_float
    percentage * 1.0 / 100
  end

  def multiplier
    1 - percentage_float
  end

  def apply_to(subtotal)
    subtotal - discount_for(subtotal)
  end

  def discount_for(subtotal)
    return Money.zero unless applies_to_total?(subtotal)
    result = subtotal * percentage_float
    result = [result, max_discount].min if max_discount?
    result
  end

  def max_discount?
    max_discount_cents.present? && max_discount > Money.zero
  end

  def applies_to_total?(subtotal)
    return true if min_amount_cents.nil?
    subtotal >= min_amount
  end

end
