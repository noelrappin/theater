class User < ActiveRecord::Base

  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, if: :new_record?

  has_many :tickets
  has_many :subscriptions

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## START: code.user_tickets_in_cart
  def tickets_in_cart
    tickets.waiting.all.to_a
  end
  ## END: code.user_tickets_in_cart

  def subscriptions_in_cart
    subscriptions.waiting.all.to_a
  end

  def attach_to_stripe(token:, plan:)
    stripe_customer = StripeCustomer.create(
      token: token, plan: plan, email: email)
    self.stripe_id = stripe_customer.id
    stripe_customer
  end

end
