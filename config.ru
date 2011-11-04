require 'bundler'
require './app'

Bundler.require

use Rack::ShowExceptions

run App.new