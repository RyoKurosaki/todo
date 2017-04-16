class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private
    def check_admin_user
      unless current_user.admin?
        respond_to do |format|
          format.html {redirect_to root_path, alert: 'You do not have an authority.' }
        end
      end
    end

  before_action :configure_permitted_parameters, if: :devise_controller?
  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) do |user_params|
        user_params.permit(:name)
      end
      devise_parameter_sanitizer.permit(:account_update) do |user_params|
        user_params.permit(:name)
      end
    end
end
