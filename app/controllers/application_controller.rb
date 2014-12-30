class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate
  before_filter :authorize

  def authenticate
    unless github_authenticated?
      github_authenticate!
    end
  end

  def authorize
    session[:authorized] ||= github_user.organization_member?('OregonDigital')
    render :status => 403, :text => "Not Authorized" unless session[:authorized] == true
  end

end
