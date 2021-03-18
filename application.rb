# frozen_string_literal: true

SINATRA_ENV = ENV.fetch("SINATRA_ENV") do |el|
  require 'dotenv/load'
  ENV.fetch(el)
end.to_sym

require 'bundler'

Bundler.require(:default, SINATRA_ENV)

# Sinatra app below

require "./models/cook_roulette/ip_address"

before do
  if CookRoulette::IpAddress.forbidden?(request.ip)
    halt 403
  end
end

get '/' do
  erb :"form.html"
end

post "/recipes" do
  @recipe_url = params["recipe_url"]
  erb :"form.html"
end
