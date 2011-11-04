#!/usr/bin/env ruby
require 'sinatra'

class App < Sinatra::Application
  load 'routes/*.rb'
end
