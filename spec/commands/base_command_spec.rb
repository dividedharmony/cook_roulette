# frozen_string_literal: true

require './commands/base_command'

RSpec.describe Commands::BaseCommand do
  let(:params) { instance_double(Sinatra::IndifferentHash) }
  let(:request) { instance_double(Sinatra::Request) }
  let(:command) { described_class.new(request, params) }

  describe ".call" do
    subject { described_class.call(request: request, params: params) }

    it "is not implemented" do
      expect { subject }.to raise_error(NotImplementedError, "Commands::BaseCommand has not implemented a #result method.")
    end
  end

  describe "#result" do
    subject { command.result }

    it "is not implemented" do
      expect { subject }.to raise_error(NotImplementedError, "Commands::BaseCommand has not implemented a #result method.")
    end
  end

  describe "#locals" do
    subject { command.locals }

    it { is_expected.to eq({}) }
  end

  describe "#template_file" do
    subject { command.template_file }

    it "is not implimented" do
      expect { subject }.to raise_error(NotImplementedError, "Commands::BaseCommand has not implemented a #template_file method.")
    end
  end

  describe "#flash" do
    subject { command.flash }

    it { is_expected.to be_instance_of(CookRoulette::Flash) }
  end

  describe "subclassing" do
    let(:params) { instance_double(Sinatra::IndifferentHash) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:subclass) do
      Class.new(described_class) do
        def result
          "Result of subclass"
        end

        def template_file
          "example.html.erb"
        end
      end
    end
    let(:command) { subclass.new(request, params) }

    describe ".call" do
      subject { subclass.call(request: request, params: params) }
    end

    describe "#result" do
      subject { command.result }

      it { is_expected.to eq("Result of subclass") }
    end

    describe "#locals" do
      subject { command.locals }

      it { is_expected.to eq({}) }
    end

    describe "#template_file" do
      subject { command.template_file }

      it { is_expected.to eq("example.html.erb") }
    end
  end
end
