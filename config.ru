require 'rubygems'
require 'sinatra'
require './clickistrano'
set :run, false
set :environment, :production
run Sinatra::Application
