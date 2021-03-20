# frozen_string_literal: true

require './models/recipe'

RSpec.describe Recipe do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  describe "validations" do
    describe "name" do
      subject(:recipe) { 
        described_class.new(url: "https://www.example.com", name: "Cool") 
      }

      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end

    describe "url" do
      subject(:recipe) { 
        described_class.new(url: "https://www.example.com", name: "Cool") 
      }

      it { is_expected.to validate_presence_of(:url) }
      it { is_expected.to validate_uniqueness_of(:url).case_insensitive }
      it "vaidates format of :url" do
        expect(subject).to allow_values(
          "http://www.example.com",
          "http://example.com",
          "https://www.example.com/somewhere",
          "https://subdomain.example.ninja/go?params=x",
        ).for(:url)
        expect(subject).not_to allow_values(
          "invalid_protocol://www.example.com",
          "https://wwwnodotscom/somewhere",
          "https://www.onedot",
        ).for(:url)
      end
    end
  end
end
