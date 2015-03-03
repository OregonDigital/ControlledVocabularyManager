class LoginController < ApplicationController
  skip_before_filter :check_auth
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
      flash[:notice] = "Authorization failed"
    end
    if session[:user_route]
      redirect_to session[:user_route]
    else flash[:notice] = "You are logged in"
      redirect_to "/"
    end
  end

  def destroy
    github_logout
    session[:authorized] = false
    session.delete(:user_route)
    flash[:notice] = "You have logged out"
    redirect_to "/"
  end
end
