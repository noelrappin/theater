class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
  end

  # START: with_discount
  def create
    if params[:discount_code].present?
      session[:new_discount_code] = code
      redirect_to shopping_cart_path
      return
    end
    workflow = create_workflow(params[:payment_type], params[:purchase_type])
    workflow.run
    if workflow.success
      redirect_to workflow.redirect_on_success_url ||
                  payment_path(id: workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end
  # END: with_discount

  private def failure_path
    shopping_cart_path
  end

  private def create_workflow(payment_type, purchase_type)
    case purchase_type
    when "SubscriptionCart"
      stripe_subscription_workflow
    when "ShoppingCart"
      (payment_type == "paypal") ? paypal_workflow : stripe_workflow
    end
  end

  private def stripe_subscription_workflow
    StripeCreatesSubscription.new(
      user: current_user,
      expected_subscription_id: params[:subscription_ids].first,
      token: StripeToken.new(**card_params))
  end

  private def paypal_workflow
    PayPalPurchasesCart.new(
      user: current_user,
      purchase_amount_cents: params[:purchase_amount_cents],
      expected_ticket_ids: params[:ticket_ids])
  end

  private def stripe_workflow
    reference = Payment.generate_reference
    PurchasesCartSetupJob.perform_later(
      user: current_user, params: params, payment_reference: reference)
  end

  private def card_params
    params.slice(:credit_card_number, :expiration_month,
                 :expiration_year, :cvc, :stripe_token).symbolize_keys
  end

end
