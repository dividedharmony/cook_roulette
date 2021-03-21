# frozen_string_literal: true

require './models/cook_roulette/flash'

module Commands
  class BaseCommand
    def initialize(request:, params:)
      @request = request
      @params = params
      @flash = CookRoulette::Flash.new
    end

    def success?
      raise NotImplementedError, "#{self.class.name} has not implemented a #success? method."
    end

    def locals
      {}
    end

    def template_file
      raise NotImplementedError, "#{self.class.name} has not implemented a #template_file method."
    end

    attr_reader :flash

    private

    attr_reader :request, :params
  end
end
