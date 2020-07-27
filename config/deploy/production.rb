require 'yaml'
config = YAML.load_file('config/config.yml')["deployment"]["production"] || {}

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}
server "#{config['host']}", user: "#{config['user']}", roles: %w{app db web}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :web, config['hosts']['web'] # Your HTTP server, Apache/etc
# role :app, config['hosts']['app'] # This may be the same as your `Web` server
# role :db,  config['hosts']['db'] # This is where Rails migrations will run


# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Git Config
set :branch, config['branch']

# God Settings
set(:god_app_path) {"#{current_path}/#{config['god']['app_path']}"}
set :god_sites_path,  config['god']['sites_path']
set :deploy_to, config['deploy_to']
set :rails_env, :production

# Deploy Commands
# Override deploy to inform god to do the restarts.
namespace :deploy do
  task :start do
    god.start
  end
  task :stop do
    god.stop
  end
  task :restart do
    god.restart
  end
end

namespace :god do
  desc "Reload god config"
  task :reload, :roles => :app, :except => {:no_release => true} do
    run "ln -nfs #{god_app_path} #{god_sites_path}/#{application}.conf"
    sudo "/etc/init.d/god restart"
  end

  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{shared_path}/tmp/restart.txt"
  end

  task :start, :roles => :app do
    sudo "/etc/init.d/god startapp #{application}"
  end

  task :stop, :roles => :app do
    sudo "/etc/init.d/god stopapp #{application}"
  end

  task :status, :roles => :app do
    sudo "/etc/init.d/god status #{applictaion}"
  end
end


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
 set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
   forward_agent: false,
#    auth_methods: %w(password)
 }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
