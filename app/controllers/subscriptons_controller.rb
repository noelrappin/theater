class SubscriptionsController < ApplicationController

  def delete
    workflow = CancelsStripeSubscription(
      subscription_id: params[:id], user: current_user)
    redirect_to: current_user
  end

end
