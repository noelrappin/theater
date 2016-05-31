require "administrate/base_dashboard"

class PaymentDashboard < Administrate::BaseDashboard

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    payment_line_items: Field::HasMany,
    references: Field::HasMany,
    id: Field::Number,
    price_cents: Field::Number,
    status: Field::String.with_options(searchable: false),
    reference: Field::String,
    payment_method: Field::String,
    response_id: Field::String,
    full_response: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime}.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :payment_line_items,
    :references,
    :id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :payment_line_items,
    :id,
    :price_cents,
    :status,
    :reference,
    :payment_method,
    :response_id,
    :full_response,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :payment_line_items,
    :price_cents,
    :status,
    :reference,
    :payment_method,
    :response_id,
    :full_response
  ].freeze

  # Overwrite this method to customize how payments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(payment)
  #   "Payment ##{payment.id}"
  # end

end
