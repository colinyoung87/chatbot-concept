require_relative './app'
run Rack::URLMap.new('/' => App::Base)