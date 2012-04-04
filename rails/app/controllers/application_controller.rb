class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_time_zone

  private
  def current_user
    @current_user ||= Researcher.select([:id, :name, :user_name, :time_zone]).where(id: session[:researcher_id]).first if session[:researcher_id]
  end
  def login_required
    if current_user.nil?
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end

  def admin_required
    if current_user.nil? || (Researcher.find(current_user.id) && !Researcher.find(current_user.id).admin?)
      redirect_to root_path, alert: "You must be an admin in to view this page."
    end
  end

  def set_time_zone
    Time.zone = current_user ? current_user.time_zone : WWW140kit::Application.config.time_zone
  end
end
