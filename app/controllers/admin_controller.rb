class AdminController < ApplicationController
  before_filter :require_admin
  
  def index
    
  end

  private

  def require_admin
    render :status => :unauthorized, :text => 'Only admin can access' unless current_user && current_user.admin?
  end

  def require_editor
    render :status => :unauthorized, :text => 'Only a user with proper permissions can access' unless current_user && current_user.editor?
  end

  def require_reviewer
    render :status => :unauthorized, :text => 'Only a user with proper permissions can access' unless current_user && current_user.reviewer?
  end
end
