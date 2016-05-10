class AdminController < ApplicationController
  before_filter :require_admin
  
  def index
    
  end

  private

  def require_admin
    render :status => :unauthorized, :text => 'Only admin can access' unless current_user && current_user.admin?
  end
end
