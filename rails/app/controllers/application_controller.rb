class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  private
  def current_user
    @current_user ||= Researcher.select(:id).where(id: session[:researcher_id]).first if session[:researcher_id]
  end
  def login_required
    if current_user.nil?
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end
end
