class LoginController < ApplicationController

  def index
  end

  def doauth
    if session[:authorized] != true
      authenticate
      authorize
    else
     destroy
    end
  end

  def authenticate
    unless github_authenticated?
      github_authenticate!
    end
  end

  def authorize
    session[:authorized] ||= github_user.organization_member?('OregonDigital')
    if session[:authorized] != true
      flash.keep[:notice] = "authorization failed"
    end
   session[:user_route] ||= "/"
   redirect_to session[:user_route]
  end

  def destroy
    github_logout
    session[:authorized] = false
    session.delete(:user_route)
    flash[:notice] = "You have logged out"
    redirect_to "/"
  end
end
