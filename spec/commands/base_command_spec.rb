# frozen_string_literal: true

require './commands/base_command'

RSpec.describe Commands::BaseCommand do
  describe "#success?" do
    let(:params) { instance_double(Sinatra::IndifferentHash) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:command) { described_class.new(request: request, params: params) }

    subject { command.success? }

    it "is not implemented" do
      expect { subject }.to raise_error(NotImplementedError, "Commands::BaseCommand has not implemented a #success? method.")
    end
  end

  describe "#locals" do
    let(:params) { instance_double(Sinatra::IndifferentHash) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:command) { described_class.new(request: request, params: params) }

    subject { command.locals }

    it { is_expected.to eq({}) }
  end

  describe "#template_file" do
    let(:params) { instance_double(Sinatra::IndifferentHash) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:command) { described_class.new(request: request, params: params) }

    subject { command.template_file }

    it "is not implimented" do
      expect { subject }.to raise_error(NotImplementedError, "Commands::BaseCommand has not implemented a #template_file method.")
    end
  end

  describe "subclassing" do
    let(:params) { instance_double(Sinatra::IndifferentHash) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:subclass) do
      Class.new(described_class) do
        def success?
          true
        end

        def template_file
          "example.html.erb"
        end
      end
    end
    let(:command) { subclass.new(request: request, params: params) }

    describe "#success?" do
      subject { command.success? }

      it { is_expected.to be true }
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
