class Plan < ActiveRecord::Base

  def remote_plan
    @remote_plan ||= Stripe::Plan.retrieve(remote_id)
  end

end
