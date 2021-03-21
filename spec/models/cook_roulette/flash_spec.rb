# frozen_string_literal: true

require './models/cook_roulette/flash'

RSpec.describe CookRoulette::Flash do
  let(:flash) { described_class.new }

  describe "#clear!" do
    before do
      flash.success = "Cool Town"
    end

    subject { flash.clear! }

    it "removes all message values" do
      expect { subject }.to change { flash.success }.from("Cool Town").to(nil)
    end
  end

  describe "#present?" do
    subject { flash.present? }

    context "if flash has no message values" do
      it { is_expected.to be false }
    end

    context "if flash has at least one message value" do
      before do
        flash.success = "Blah blah"
      end

      it { is_expected.to be true }
    end
  end

  describe "#empty?" do
    subject { flash.empty? }

    context "if flash has no message values" do
      it { is_expected.to be true }
    end

    context "if flash has at least one message value" do
      before do
        flash.error = "Blah blah"
      end

      it { is_expected.to be false }
    end
  end

  describe "success= and success" do
    subject { flash.success = "Bravo" }

    it "gets and sets the success message" do
      expect { subject }.to change { flash.success }.from(nil).to("Bravo")
    end
  end

  describe "info= and info" do
    subject { flash.info = "FYI" }

    it "gets and sets the success message" do
      expect { subject }.to change { flash.info }.from(nil).to("FYI")
    end
  end

  describe "warning= and warning" do
    subject { flash.warning = "Caution!" }

    it "gets and sets the success message" do
      expect { subject }.to change { flash.warning }.from(nil).to("Caution!")
    end
  end

  describe "error= and error" do
    subject { flash.error = "Danger Will Robinson!" }

    it "gets and sets the success message" do
      expect { subject }.to change { flash.error }.from(nil).to("Danger Will Robinson!")
    end
  end

  describe "#method_missing?" do
    context "if method_name ends in a '='" do
      context "if method_name is not a flash_type" do
        subject { flash.unreal_method = 25 }
  
        it "raises an error" do
          expect { subject }.to raise_error(NoMethodError)
        end
      end
    end

    context "if method_name does not end in a '='" do
      context "if method_name is not a flash_type" do
        subject { flash.not_real_method }
  
        it "raises an error" do
          expect { subject }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
