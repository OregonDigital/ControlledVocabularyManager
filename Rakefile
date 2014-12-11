# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'jettywrapper'

MARMOTTA_HOME = ENV['MARMOTTA_HOME'] || File.expand_path(File.join(Jettywrapper.app_root, 'marmotta'))
Jettywrapper.url = "https://github.com/dpla/marmotta-jetty/archive/3.3.0-release-candidate.zip"

Rails.application.load_tasks
