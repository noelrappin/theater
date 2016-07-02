module Admin

  class UsersController < Admin::ApplicationController

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

  end

end
