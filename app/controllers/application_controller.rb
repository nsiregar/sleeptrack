class ApplicationController < ActionController::API
  def current_user
    @current_user ||= User.find(params[:user_id])
  end
end
