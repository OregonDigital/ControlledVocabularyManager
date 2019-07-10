# This file is used by Rack-based servers to start the application.

# Initialize Honeycomb before everything else
require 'honeycomb-beeline'
Honeycomb.init

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
