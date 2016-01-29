class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
  end

  def create
    reference = Payment.generate_reference
    PurchasesCartJob.perform_later(
      user: current_user, params: params, payment_reference: reference)
    redirect_to order_path(id: reference)
  end

end
