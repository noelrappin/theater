require "administrate/base_dashboard"

class DiscountCodeDashboard < Administrate::BaseDashboard

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    code: Field::String,
    percentage: Field::Number,
    description: Field::Text,
    min_amount_cents: Field::Number,
    max_discount_cents: Field::Number,
    max_uses: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime}.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :code,
    :percentage,
    :description
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :code,
    :percentage,
    :description,
    :min_amount_cents,
    :max_discount_cents,
    :max_uses,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :code,
    :percentage,
    :description,
    :min_amount_cents,
    :max_discount_cents,
    :max_uses
  ].freeze

  # Overwrite this method to customize how discount codes are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(discount_code)
  #   "DiscountCode ##{discount_code.id}"
  # end

end
