require_relative 'boot'

require 'rails/all'
require 'json/ld'
require_relative '../lib/conneg_middleware'
require 'triplestore_adapter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ControlledVocabularyManager
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true

    Rails.application.routes.default_url_options[:host] = 'opaquenamespace.org'
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)
    config.middleware.use ::ConnegMiddleware
    config.encoding = "utf-8"
  end
end
