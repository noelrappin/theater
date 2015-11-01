class User < ActiveRecord::Base

  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, if: :new_record?

  has_many :tickets

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def tickets_in_cart
    tickets.waiting.all.to_a
  end

end
