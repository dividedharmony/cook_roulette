# frozen_string_literal: true

module Commands
  class BaseCommand
    def initialize(request:, params:)
      @request = request
      @params = params
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

    private

    attr_reader :request, :params
  end
end
