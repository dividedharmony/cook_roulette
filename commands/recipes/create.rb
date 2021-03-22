# frozen_string_literal: true

require 'dry/monads/do'

require './models/recipe'
require './models/line_item'
require './commands/base_command'
require './services/parse_recipe'

module Commands
  module Recipes
    class Create < BaseCommand
      include Dry::Monads::Do.for(:result)

      def result
        given_url       = yield get_url
        parse_result    = yield ParseRecipe.(url: given_url)
        @recipe         = yield create_recipe(parse_result)
        @recipe         = yield create_line_items(@recipe, parse_result)
        Success(self)
      end

      def locals
        {
          recipe: @recipe
        }
      end

      attr_reader :recipe

      private

      def get_url
        given_url = params["recipe_url"]&.strip
        if given_url.nil? || given_url.length.zero?
          Failure("Please provide a URL.")
        else
          Success(given_url)
        end
      end

      def create_recipe(parse_result)
        new_recipe = Recipe.new(
          name: parse_result.recipe_title,
          url: parse_result.recipe_url
        )
        if new_recipe.save
          Success(new_recipe)
        else
          Failure(new_recipe.errors.full_messages.join("\n"))
        end
      end

      def create_line_items(recipe, parse_result)
        errors = []
        parse_result.ingredient_list.each do |ingredient_text|
          line_item = recipe.line_items.new(raw_text: ingredient_text)
          errors << line_item.errors.full_messages unless line_item.save
        end
        if errors.any?
          Failure(errors.flatten.join("\n"))
        else
          Success(recipe.reload)
        end
      end
    end
  end
end
