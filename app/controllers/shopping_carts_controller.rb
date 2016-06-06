class ShoppingCartsController < ApplicationController

  # START: shopping_cart_show
  def show
    @cart = ShoppingCart.new(current_user, session[:new_discount_code])
  end
  # END: shopping_cart_show

  def update
    performance = Performance.find(params[:performance_id])
    workflow = AddsToCart.new(user: current_user,
                              performance: performance,
                              count: params[:ticket_count])
    workflow.run
    if workflow.result
      redirect_to shopping_cart_path
    else
      redirect_to performance.event
    end
  end

end
