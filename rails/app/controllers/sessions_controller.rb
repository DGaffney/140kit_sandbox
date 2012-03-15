class SessionsController < ApplicationController
  def create
    # raise request.env["omniauth.auth"].to_yaml
    auth = request.env["omniauth.auth"]
    researcher = Researcher.find_by_provider_and_uid(auth["provider"], auth["uid"]) || Researcher.create_with_omniauth(auth)
    session[:researcher_id] = researcher.id
    redirect_to root_url, :notice => "Signed in!"
  end
  def destroy
    session[:researcher_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
  def fail
    redirect_to root_url, :notice => "We're sorry, but something went wrong when you tried to log in. Care to try again?"
  end
end
