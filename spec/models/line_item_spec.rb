# frozen_string_literal: true

require './models/line_item'

RSpec.describe LineItem do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  describe "validations" do
    describe "raw_text" do
      subject(:ingredient) { 
        described_class.new(raw_text: "3 sliced Avocados") 
      }

      it { is_expected.to validate_presence_of(:raw_text) }
    end
  end
end
