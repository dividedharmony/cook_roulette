# frozen_string_literal: true

require './models/ingredient'

RSpec.describe Ingredient do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  describe "associations" do
    it { is_expected.to have_many(:line_items) }
    it { is_expected.to have_many(:recipes).through(:line_items) }
  end

  describe "validations" do
    describe "name" do
      subject(:ingredient) { 
        described_class.new(name: "Carrot") 
      }

      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
  end
end
