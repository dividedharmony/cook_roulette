# frozen_string_literal: true

SINATRA_ENV = ENV.fetch("SINATRA_ENV") do |el|
  require 'dotenv/load'
  ENV.fetch(el)
end.to_sym

require 'bundler'

Bundler.require(:default, SINATRA_ENV)

get '/' do
  erb :"form.html"
end
