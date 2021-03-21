# frozen_string_literal: true

module CookRoulette
  class Flash
    FLASH_TYPES = %i(success info warning error)

    attr_reader :messages

    def initialize
      @messages = {}
      clear!
    end

    def clear!
      FLASH_TYPES.each do |flash_type|
        messages[flash_type] = nil
      end
    end

    def present?
      messages.values.any? do |msg_value|
        msg_value && msg_value.length > 0
      end
    end

    def empty?
      !present?
    end

    private

    def method_missing(method_name, *args, **options, &block)
      name_without_assign = method_name.to_s.delete('=').to_sym
      return super unless FLASH_TYPES.include?(name_without_assign)
      if method_name.to_s.end_with?('=')
        messages[name_without_assign] = args.first
      else
        messages[name_without_assign]
      end
    end
  end
end
