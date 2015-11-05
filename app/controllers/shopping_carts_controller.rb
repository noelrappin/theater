class ShoppingCartsController < ApplicationController

  def show
    @cart = ShoppingCart.new(current_user)
  end

  # #START: code.shopping_cart_update
  def update
    performance = Performance.find(params[:performance_id])
    action = AddsToCart.new(
      user: current_user, performance: performance, count: params[:ticket_count])
    action.run
    if action.result
      redirect_to shopping_cart_path
    else
      redirect_to performance.event
    end
  end
  # #END:  code.shopping_cart_update

end
