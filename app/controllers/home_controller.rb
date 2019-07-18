# frozen_string_literal: true

# Home Controller
class HomeController < ApplicationController
  def index; end

  def nav
    render partial: 'shared/navbar', layout: false
  end

  def can_edit
    render json: { can_edit: current_user && current_user.editor? }
  end
end
