class DiscountCodeSerializer < ActiveModel::Serializer
  attributes :id, :code, :percentage, :description, :min_amount_cents, :max_discount_cents, :max_uses
end
