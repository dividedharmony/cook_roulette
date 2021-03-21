# frozen_string_literal: true

require 'dry/monads'
require './models/cook_roulette/flash'

module Commands
  class BaseCommand
    include Dry::Monads[:result]

    def self.call(request:, params:)
      self.new(request, params).result
    end

    def initialize(request, params)
      @request = request
      @params = params
      @flash = CookRoulette::Flash.new
    end

    def result
      raise NotImplementedError, "#{self.class.name} has not implemented a #result method."
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
