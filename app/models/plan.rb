class Plan < ActiveRecord::Base

  has_paper_trail

  enum status: %i(inactive active).freeze

  monetize :price_cents

  def remote_plan
    @remote_plan ||= Stripe::Plan.retrieve(remote_id)
  end

  def end_date_from(date = nil)
    date ||= Time.zone.now.to_date
    1.send(interval).from_now(date)
  end

end
