class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    return nil if session[:awaiting_authy_user_id].present?
    super
  end

  def user_for_paper_trail
    simulating_admin_user || current_user
  end

  def simulating_admin_user
    User.find_by(id: session[:admin_id])
  end
  helper_method :simulating_admin_user

  private def user_not_authorized
    sign_out(User)
    render plain: "Access Not Allowed", status: :forbidden
  end

end
