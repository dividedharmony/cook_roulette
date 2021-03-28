# frozen_string_literal: true

require 'dry/monads/do'

require './models/recipe'
require './models/ingredient'
require './models/line_item'
require './commands/base_command'
require './services/parse_recipe'

module Commands
  module Ingredients
    class Create < BaseCommand
      include Dry::Monads::Do.for(:result)

      def result
        @line_item = yield find_line_item
        @ingredient = yield find_or_create_ingredient
        yield save_association(@line_item, @ingredient)
        Success(self)
      end

      def success_path
        recipe = @line_item.recipe
        "/recipes/#{recipe.id}"
      end

      private

      def find_or_create_ingredient
        case params['ingredient_source']
        when "new-ingredient"
          create_ingredient
        when "old-ingredient"
          find_ingredient
        else
          Failure("Invalid Ingredient Source Type!")
        end
      end

      def find_line_item
        line_item_id = params["line_item_id"]
        line_item = LineItem.find_by(id: line_item_id)
        if line_item.nil?
          Failure("Could not find line_item with id #{line_item_id.inspect}")
        else
          Success(line_item)
        end
      end

      def save_association(line_item, ingredient)
        if line_item.update(ingredient: ingredient)
          Success(line_item)
        else
          Failure(line_item.errors.full_messages.join("\n"))
        end
      end

      def find_ingredient
        ingredient_id = params["ingredient_id"]
        ingredient = Ingredient.find_by(id: ingredient_id)
        if ingredient.nil?
          Failure("Could not find ingredient with id #{ingredient_id.inspect}")
        else
          Success(ingredient)
        end
      end

      def create_ingredient
        new_ingredient = Ingredient.new(
          name: params["ingredient_name"]
        )
        if new_ingredient.save
          Success(new_ingredient)
        else
          Failure(new_ingredient.errors.full_messages.join("\n"))
        end
      end
    end
  end
end
