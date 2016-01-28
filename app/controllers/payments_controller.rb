class PaymentsController < ApplicationController

  def show
    @payment = Payment.find_by(reference: params[:id])
  end

  def create
    token = StripeToken.new(**card_params)
    workflow = PurchasesCart.new(
      user: current_user, stripe_token: token,
      purchase_amount_cents: params[:purchase_amount_cents],
      expected_ticket_ids: params[:ticket_ids])
    workflow.run
    if workflow.success
      redirect_to payment_path(id: workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end

  # START: card_params
  private def card_params
    params.slice(:credit_card_number, :expiration_month,
                 :expiration_year, :cvc, :stripe_token).symbolize_keys
  end
  # END: card_params

end