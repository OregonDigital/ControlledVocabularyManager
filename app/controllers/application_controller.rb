class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_auth

  private

  def check_auth
    if session[:authorized] != true
      session[:user_route] = request.env['PATH_INFO']
      redirect_to '/login'
    end
  end

end
