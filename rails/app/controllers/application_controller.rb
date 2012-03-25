class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  private
  def current_user
    @current_user ||= Researcher.select([:id, :name, :user_name]).where(id: session[:researcher_id]).first if session[:researcher_id]
  end
  def login_required
    if current_user.nil?
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end

  def admin_required
    if current_user.nil? || (Researcher.find(current_user.id) && !Researcher.find(current_user.id).admin?)
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end
end
