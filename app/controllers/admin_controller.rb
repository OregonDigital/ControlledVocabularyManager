class AdminController < ApplicationController
  #Except show and index is important for fetching ntriples and other data types.
  before_filter :require_admin, :except => [:index, :show]
  
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
