require "administrate/base_dashboard"

class TicketDashboard < Administrate::BaseDashboard

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    performance: Field::BelongsTo,
    event: Field::HasOne,
    id: Field::Number,
    status: Field::String.with_options(searchable: false),
    access: Field::String.with_options(searchable: false),
    price_cents: Field::Number,
    reference: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    payment_reference: Field::String}.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :performance,
    :event,
    :id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :performance,
    :event,
    :id,
    :status,
    :access,
    :price_cents,
    :reference,
    :created_at,
    :updated_at,
    :payment_reference
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :performance,
    :event,
    :status,
    :access,
    :price_cents,
    :reference,
    :payment_reference
  ].freeze

  # Overwrite this method to customize how tickets are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(ticket)
  #   "Ticket ##{ticket.id}"
  # end

end
