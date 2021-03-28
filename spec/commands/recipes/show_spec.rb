# frozen_string_literal: true

require './commands/recipes/show'

RSpec.describe Commands::Recipes::Show do
  let(:given_id) { 999_999_999 }
  let(:params) do
    indiff_hash = Sinatra::IndifferentHash.new
    indiff_hash["id"] = given_id
    indiff_hash
  end
  let(:request) { instance_double(Sinatra::Request) }
  let(:command) { described_class.new(request, params) }

  describe "#result" do
    subject { command.result }

    context "if no recipe can be found with given id" do
      it "returns a Failure monad" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq(
          "Could not find Recipe with id 999999999"
        )
      end
    end

    context "if a recipe can be found with given id" do
      let!(:recipe) { Recipe.create!(name: "Cool", url: "https://www.example.com/abc") }
      let(:given_id) { recipe.id }

      it "finds the recipe and wraps it in a Success monad" do
        expect(subject).to be_success
        show_cmd = subject.value!
        expect(show_cmd.locals[:recipe]).to eq(recipe)
      end
    end
  end
end
