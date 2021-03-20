# frozen_string_literal: true

require './models/cook_roulette/ip_address'

RSpec.describe CookRoulette::IpAddress do
  describe ".forbidden?" do
    subject { described_class.forbidden?(given_ip_address) }

    context "if ALLOWED_IP_ADDRESSES env var includes given ip address" do
      let(:given_ip_address) { ENV.fetch("ALLOWED_IP_ADDRESSES").split(",").first }

      it { is_expected.to be false }
    end

    context "if ALLOWED_IP_ADDRESSES env var does not include given ip address" do
      let(:given_ip_address) { "131.not.real.2" }

      it { is_expected.to be true }
    end
  end
end
