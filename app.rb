#!/usr/bin/env ruby
require 'sinatra'

class App < Sinatra::Application
  Dir.glob("routes/*.rb").each { |route| require './' + route }
end
