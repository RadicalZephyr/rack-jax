require 'java'
require 'jax-server-0.1.0.jar'

require 'rack_jax/version'
require 'rack_jax/app_wrapper'
require 'rack_jax/input_wrapper'

require 'rack/handler/rack_jax'
require 'rack/handler'

Rack::Handler.register('rack_jax', 'Rack::Handler::RackJax')
