class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
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
      user: current_user,
      purchase_amount_cents: params[:purchase_amount_cents],
      expected_ticket_ids: params[:ticket_ids])
  end

  private def stripe_workflow
    reference = Payment.generate_reference
    PurchasesCartJob.perform_later(
      user: current_user, params: params, payment_reference: reference)
  end

  private def card_params
    params.slice(:credit_card_number, :expiration_month,
                 :expiration_year, :cvc, :stripe_token).symbolize_keys
  end

end
