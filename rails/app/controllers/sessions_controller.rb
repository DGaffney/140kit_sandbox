class SessionsController < ApplicationController
  def create
    # raise request.env["omniauth.auth"].to_yaml
    auth = request.env["omniauth.auth"]
    debugger
    researcher = Researcher.find_by_provider_and_uid(auth["provider"], auth["uid"]) || Researcher.create_with_omniauth(auth)
    session[:researcher_id] = researcher.id
    if researcher.first_time
      redirect_to new_researcher_url(researcher), flash: { success: "Welcome, #{researcher.name}!" }
    else
      redirect_to request.referer || dashboard_url, flash: { success: "Hi, #{researcher.name}!" }
    end

  end

  def destroy
    session[:researcher_id] = nil
    redirect_to request.referer || root_url, flash: { success: "Signed out." }
  end

  def fail
    redirect_to root_url, :error => "We're sorry, but something went wrong when you tried to log in. Care to try again?"
  end
end
