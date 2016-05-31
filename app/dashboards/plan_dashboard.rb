require "administrate/base_dashboard"

class PlanDashboard < Administrate::BaseDashboard

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    remote_id: Field::String,
    plan_name: Field::String,
    price_cents: Field::Number,
    interval: Field::String,
    tickets_allowed: Field::Number,
    ticket_category: Field::String,
    status: Field::String.with_options(searchable: false),
    description: Field::String}.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id, :remote_id, :plan_name, :price_cents
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id, :remote_id, :plan_name, :price_cents, :interval, :tickets_allowed,
    :ticket_category, :status,
    :description
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :remote_id, :plan_name, :price_cents, :interval, :tickets_allowed,
    :ticket_category, :status, :description
  ].freeze

  # Overwrite this method to customize how plans are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(plan)
    plan.plan_name
  end

end
