# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def skip_render_on_cached_page
    @skip_render = true
  end

  if %w[production staging].include? Rails.env
    def append_info_to_payload(payload)
      super(payload)
      Rack::Honeycomb.add_field(request.env, 'classname', self.class.name)
    end
  end
end
