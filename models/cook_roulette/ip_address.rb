# frozen_string_literal: true

module CookRoulette
  class IpAddress
    ALLOWED_IP_ADDRESSES = ENV.fetch("ALLOWED_IP_ADDRESSES").split(",").freeze

    def self.forbidden?(request_ip)
      ALLOWED_IP_ADDRESSES.none? { |allowed| allowed == request_ip }
    end
  end
end
