class PurchasesCartSetupJob < ActiveJob::Base

  queue_as :default

  def perform(user:, params:, order_reference:)
    token = StripeToken.new(**card_params(params))
    purchases_cart_action = PurchasesCartSetup.new(
      user: user, stripe_token: token, purchase_amount_cents:
      params[:purchase_amount_cents], expected_ticket_ids: params[:ticket_ids],
      order_reference: order_reference)
    purchases_cart_action.run
  end

  private def card_params(params)
    params.slice(:credit_card_number, :expiration_month,
                 :expiration_year, :cvc, :stripe_token).symbolize_keys
  end

end
