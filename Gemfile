source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'
gem 'actionpack-page_caching'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2', '~> 0.3.13'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Bootstrap
gem 'bootstrap-sass', '~> 3.4'
gem 'autoprefixer-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

gem 'rest-client'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use unicorn as the app server
gem 'unicorn'

# Use for getting the ISO639 language sets easily
gem 'iso-639'

# Active Triples for RDF resources.
gem 'active-triples', '~> 0.6.0'
gem 'rdf-vocab'
gem "sparql-client", '~> 1.99'
gem 'triplestore-adapter', :github => "osulp/triplestore-adapter", :branch => "0.1.0"
gem 'json-ld', '~> 1.99'

gem 'warden-github-rails'
gem 'rugged'

gem 'config'
gem 'simple_form'
gem 'coveralls'
gem 'passenger'

gem 'devise'
gem 'cancan'

gem 'font-awesome-rails'

gem 'attr_extras'

gem 'capistrano', '~> 2.0'

gem 'responders', '~> 2.0'

gem 'sunspot'

gem 'will_paginate', '~> 3.1.0'
gem 'bootstrap-will_paginate'

group :production, :staging do
  gem 'ddtrace'
end

group :development do
  gem 'spring-commands-rspec'
  gem 'web-console', '~> 2.0'
  gem 'sunspot_solr'
end

group :development, :test do
  gem 'awesome_print'
  # gem 'jazz_hands', :github => "terrellt/jazz_hands"
  gem 'pry'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  # Test Coverage
  gem 'simplecov'
  gem 'capybara-screenshot'
  gem 'dotenv-rails'
  gem 'warden-rspec-rails', :github => "mspanc/warden-rspec-rails"
  gem 'capybara'
end

group :test do
  gem 'poltergeist', '~> 1.9.0'
  gem 'database_cleaner'
  gem 'formulaic'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock'
end
