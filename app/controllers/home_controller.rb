class HomeController < ApplicationController
  def index
  end

  def nav
    render partial: "shared/navbar", layout: false
  end

  def admin
    render json: { admin: current_user && current_user.admin? }
  end
end
