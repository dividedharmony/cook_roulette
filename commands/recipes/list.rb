# frozen_string_literal: true

require './models/recipe'
require './models/line_item'
require './commands/base_command'

module Commands
  module Recipes
    class List < BaseCommand
      def result
        @recipes = Recipe.all
        Success(self)
      end

      def locals
        {
          recipes: @recipes
        }
      end
    end
  end
end
