# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

require 'dry/monads'
require 'dry/monads/do'

class ParseRecipe
  ParseRecipeResult = Struct.new(
    :given_url,
    :recipe_url,
    :recipe_title,
    :ingredient_list
  )

  ALL_RECIPES_REGEX = /\Ahttps:\/\/www.allrecipes.com/i
  ALL_RECIPES_TITLE_CSS = ".recipe-main-header .heading-content"
  ALL_RECIPES_INGREDIENTS_CSS = ".ingredients-item-name"

  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def self.call(url:)
    self.new(url).call
  end

  def initialize(given_url)
    @given_url = given_url
    @recipe_url = nil
    @recipe_title = nil
  end

  def call
    @recipe_url           = yield validate_url
    query_response        = yield query_recipe_url
    document              = yield parse_response(query_response.body)
    title_element         = yield get_title_element(document)
    @recipe_title         = yield parse_title_element(title_element)
    ingredient_list       = yield get_ingredients(document)
    Success(
      ParseRecipeResult.new(
        given_url,
        recipe_url,
        recipe_title,
        ingredient_list
      )
    )
  end

  private

  attr_reader :given_url, :recipe_url, :recipe_title

  def validate_url
    if given_url =~ ALL_RECIPES_REGEX
      Success(given_url)
    else
      Failure("We only support allrecipes.com currently. '#{given_url}' is not supported.")
    end
  end

  def query_recipe_url
    query_response = HTTParty.get(recipe_url)
    if query_response.code == 200
      Success(query_response)
    else
      Failure("Response from #{recipe_url} was a #{query_response.code} response.")
    end
  end

  def parse_response(response_body)
    document = Nokogiri::HTML(response_body)
    Success(document)
  rescue StandardError => e
    Failure("Could not parse response: #{e.message}")
  end

  def get_title_element(document)
    title = document.at_css(ALL_RECIPES_TITLE_CSS)
    if title.nil? 
      Failure("Could not find a title for recipe.")
    else
      Success(title)
    end
  end

  def parse_title_element(title_element)
    stripped_title = title_element.text.strip
    if stripped_title.empty?
      Failure("Title of recipe was blank or not in expected location.")
    else
      Success(stripped_title)
    end
  end

  def get_ingredients(document)
    ingredient_elements = document.css(ALL_RECIPES_INGREDIENTS_CSS)
    ingredient_list = ingredient_elements.map do |el|
      ingredient_text = el.text.strip
      ingredient_text.empty? ? nil : ingredient_text
    end.compact
    Success(ingredient_list)
  end
end
