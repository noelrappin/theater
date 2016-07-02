module Admin

  class UsersController < Admin::ApplicationController

    skip_before_action :authenticate_admin, only: [:unsimulate]

    def update
      super
      @user = User.find(params[:id])
      if @user.admin? && params[:user][:cellphone_number].present?
        authy = Authy::API.register_user(
          email: @user.email,
          cellphone: params[:user][:cellphone_number],
          country_code: "1")
        @user.update(authy_id: authy.id) if authy
      end
    end

    def simulate
      @user_to_simulate = User.find(params[:id])
      authorize(@user_to_simulate)
      session[:admin_id] = current_user.id
      sign_in(:user, User.find(params[:id]), bypass: true)
      redirect_to root_path
    end

    def unsimulate
      if User.find_by(id: session[:admin_id]).nil?
        redirect_to(admin_users_path) && return
      end
      sign_in(:user, User.find_by(id: session[:admin_id]), bypass: true)
      session[:admin_id] = nil
      redirect_to admin_users_path
    end

  end

end
