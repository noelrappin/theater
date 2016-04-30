class SubscriptionsController < ApplicationController

  def delete
    workflow = CancelsStripeSubscription(
      subscription_id: params[:id], user: current_user)
    workflow.run
    redirect_to current_user
  end

end
