require 'pry'
require 'sinatra/base'
require 'sinatra/reloader'
require 'pg'
require 'redcarpet'
require_relative "server"

run Forum::Server