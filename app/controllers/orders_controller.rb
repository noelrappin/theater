class OrdersController < ApplicationController

  def show
    @reference = params[:id]
    @order = Order.find_by(reference: @reference)
  end

  def create
    reference = Order.generate_reference
    PurchasesCartJob.perform_later(
      user: current_user, params: params, order_reference: reference)
    redirect_to order_path(id: reference)
  end

end
