class PaymentsController < ApplicationController

  def show
    @payment = Payment.find_by(reference: params[:id])
  end

  def create
    workflow = create_workflow(params[:payment_type])
    workflow.run
    if workflow.success
      redirect_to workflow.redirect_on_success_url ||
                  payment_path(id: workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end

  private def create_workflow(payment_type)
    (payment_type == "paypal") ? paypal_workflow : stripe_workflow
  end

  private def paypal_workflow
    PayPalPurchasesCart.new(
      user: current_user, purchase_amount_cents: params[:purchase_amount_cents])
  end

  private def stripe_workflow
    StripePurchasesCart.new(
      user: current_user,
      stripe_token: StripeToken.new(**card_params),
      purchase_amount_cents: params[:purchase_amount_cents])
  end

  private def card_params
    params.slice(:credit_card_number, :expiration_month,
                 :expiration_year, :cvc, :stripe_token).symbolize_keys
  end

end
