# frozen_string_literal: true

require './models/recipe'
require './models/line_item'
require './commands/base_command'

module Commands
  module Recipes
    class Show < BaseCommand
      def result
        id = params['id']
        @recipe = Recipe.find_by(id: id)
        if @recipe.nil?
          Failure("Could not find Recipe with id #{id.inspect}")
        else
          Success(self)
        end
      end

      def locals
        {
          recipe: @recipe
        }
      end
    end
  end
end
