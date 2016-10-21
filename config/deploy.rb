require 'yaml'
config = YAML.load_file('config/config.yml')["deployment"] || {}

require 'bundler/capistrano'

set :stages, config['stages'] || []
set :default_stage, config['default_stage'] || (config['stages'] || []).first
require 'capistrano/ext/multistage'

set :application, 'ControlledVocabManager'
set :repository, config['repository']
set :user, config['user']
set :default_environment, config['default_environment'] || {}
default_run_options[:pty] = true
set :scm, :git
set :branch, config['branch']
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 5
set :shared_children, shared_children + %w{pids sockets tmp public/uploads jetty}
set :ssh_options, {:forward_agent => true}

# if you want to clean up old releases on each deploy uncomment this:
after 'deploy:restart', 'deploy:cleanup'

after 'deploy:finalize_update', 'deploy:symlink_config'
after 'deploy:update_code', 'deploy:migrate'
after 'deploy:restart', 'deploy:cleanup'


namespace :deploy do
  desc "Symlinks required configuration files"
  task :symlink_config, :roles => :app do
    %w{config.yml god.conf}.each do |config_file|
      run "ln -nfs #{deploy_to}/shared/config/#{config_file} #{release_path}/config/#{config_file}"
    end
    %w{ns}.each do |config_directory|
      run "ln -nfs #{deploy_to}/shared/public/#{config_directory} #{release_path}/public/#{config_directory}"
    end
  end
  desc "Uploads local config files"
  task :upload_config, :roles => :app do
    %w{config.yml god.conf}.each do |config_file|
      top.run "mkdir -p #{deploy_to}/shared/config"
      top.upload "config/#{config_file}", "#{deploy_to}/shared/config/#{config_file}", :via => :scp
    end
  end
end
namespace :rails do
  desc "Opens up a rails console"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.bash_profile && cd #{deploy_to}/current && export RBENV_VERSION=#{config[rails_env.to_s]['default_environment']['RBENV_VERSION']} && RAILS_ENV=#{rails_env} bundle exec rails c'"
  end
end
