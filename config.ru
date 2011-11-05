require 'bundler'
require './app'

helpers do
  Dir.glob("helpers/*.rb").each { |helper| load './' + helper }
end

Bundler.require

use Rack::ShowExceptions

run App.new