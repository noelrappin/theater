class OrdersController < ApplicationController

  def show
    @order = Order.find_by(reference: params[:id])
  end

  def create
    token = StripeToken.new(**card_params)
    action = PurchasesCart.new(user: current_user, stripe_token: token,
                               purchase_amount_cents: params[:purchase_amount_cents])
    action.run
    if action.success
      redirect_to order_path(id: action.order.reference)
    else
      redirect_to shopping_cart_path
    end
  end

  private def card_params
    params.slice(
      :credit_card_number, :expiration_month, :expiration_year, :cvc).symbolize_keys
  end

end
