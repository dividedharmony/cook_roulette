# frozen_string_literal: true

APP_ENV = ENV.fetch("APP_ENV") do |el|
  require 'dotenv/load'
  ENV.fetch(el)
end.to_sym

require 'bundler'

Bundler.require(:default, APP_ENV)

# Sinatra app below

require "./models/cook_roulette/ip_address"

class CookRouletteApp < Sinatra::Base
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
end
