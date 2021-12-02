# frozen_string_literal:true

bind 'tcp://0.0.0.0:3000'
# worker pools kill the capability for ruby-debug-ide integration
# workers 1
preload_app!
environment 'development'
