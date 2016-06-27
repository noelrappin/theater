class User < ActiveRecord::Base

  has_paper_trail ignore: %i(sign_in_count current_sign_in_at last_sign_in_at
                             current_sign_in_ip last_sign_in_ip)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, if: :new_record?

  has_many :tickets
  has_many :subscriptions

  attr_accessor :cellphone_number

  def set_default_role
    self.role ||= :user
  end

  def tickets_in_cart
    tickets.waiting.all.to_a
  end

  def subscriptions_in_cart
    subscriptions.waiting.all.to_a
  end

end
