# frozen_string_literal: true

APP_ENV = ENV.fetch("APP_ENV") do |el|
  require 'dotenv/load'
  ENV.fetch(el)
end

require 'yaml'

DB_CONFIG = YAML::load(
  File.read('config/database.yml')
).fetch(APP_ENV)

require 'bundler'

Bundler.require(:default, APP_ENV.to_sym)

require 'active_record'

ActiveRecord::Base.establish_connection(DB_CONFIG)

# Sinatra app below

require "./models/cook_roulette/ip_address"
require "./commands/recipes/create"
require "./commands/recipes/show"
require "./commands/recipes/list"

class CookRouletteApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")
  # Default assets folder:
  # set :public_folder, __dir__ + "/public"

  before do
    if CookRoulette::IpAddress.forbidden?(request.ip)
      halt 403
    end
  end

  get '/' do
    @recipe_url = session["recipe_url"]
    session["recipe_url"] = nil
    erb :"homepage.html"
  end

  get '/recipes' do
    list_result = Commands::Recipes::List.(request: request, params: params)
    if list_result.success?
      list_cmd = list_result.value!
      erb :"recipes/index.html", locals: list_cmd.locals
    else
      list_result.failure
    end
  end

  post "/recipes" do
    create_result = Commands::Recipes::Create.(request: request, params: params)
    if create_result.success?
      create_cmd = create_result.value!
      redirect to("/recipes/#{create_cmd.recipe.id}")
    else
      create_result.failure
    end
  end

  get "/recipes/:id" do
    show_result = Commands::Recipes::Show.(request: request, params: params)
    if show_result.success?
      show_cmd = show_result.value!
      erb :"recipes/show.html", locals: show_cmd.locals
    else
      status 404
      show_cmd.failure
    end
  end
end
