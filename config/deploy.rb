require 'yaml'
config = YAML.load_file('config/config.yml')["deployment"] || {}

# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "ControlledVocabManager"
set :repo_url, config['repository']

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, config['deploy_to']

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/god.conf'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'pids', 'public/assets', 'public/uploads'

# Default value for default_env is {}
set :default_env, config['default_environment'] || {}

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }
set :local_user, config['user']

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
