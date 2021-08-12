# frozen_string_literal:true

bind 'tcp://0.0.0.0:3000'
# worker pools kill the capability for ruby-debug-ide integration
workers 4
preload_app!
environment 'production'
daemonize false
# Allow for `touch tmp/restart.txt` to force puma to restart the app
plugin :tmp_restart
