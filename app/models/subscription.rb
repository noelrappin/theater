class Subscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :plan

  enum status: [:active, :inactive, :waiting]

end
