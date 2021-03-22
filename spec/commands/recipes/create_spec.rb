# frozen_string_literal: true

require 'ostruct'
require './commands/recipes/create'

RSpec.describe Commands::Recipes::Create do
  let(:given_url) { "https://www.allrecipes.com/1234" }
  let(:params) do
    indiff_hash = Sinatra::IndifferentHash.new
    indiff_hash["recipe_url"] = given_url
    indiff_hash
  end
  let(:request) { instance_double(Sinatra::Request) }
  let(:command) { described_class.new(request, params) }

  describe "#result" do
    subject { command.result }

    context "if given_url is nil" do
      let(:given_url) { nil }

      it "fails" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq("Please provide a URL.")
      end
    end

    context "if given_url is a blank string" do
      let(:given_url) { "   " }

      it "fails" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq("Please provide a URL.")
      end
    end

    context "if given_url is present" do
      before do
        expect(ParseRecipe).to receive(:call).and_return(mock_parse_result)
      end

      context "if recipe at give_url is unparsable" do
        let(:mock_parse_result) do
          Dry::Monads.Failure("Not good enough!")
        end

        it "fails" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq("Not good enough!")
        end
      end

      context "if recipe at given_url is parsable" do
        let(:ingredient_list) { [] }
        let(:mock_parse_result) do
          result = OpenStruct.new
          result.recipe_url = "https://www.example.com/parsed/result"
          result.recipe_title = "Super Cheeseburger"
          result.ingredient_list = ingredient_list
          Dry::Monads.Success(result)
        end

        context "if recipe cannot be persisted" do
          before do
            # recipe names and URLs must be unique
            Recipe.create!(
              name: "Super Cheeseburger",
              url: "https://www.example.com/parsed/result"
            )
          end

          it "fails" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq("Name has already been taken\nUrl has already been taken")
          end
        end

        context "if recipe can be persisted" do
          context "if no ingredients can be persisted" do
            it "persists the recipe without any line items" do
              expect(subject).to be_success
              result_value = subject.value!
              recipe = result_value.recipe
              expect(recipe.name).to eq("Super Cheeseburger")
              expect(recipe.url).to eq("https://www.example.com/parsed/result")
              expect(recipe.line_items).to be_empty
            end
          end

          context "if ingredients can be persisted" do
            let(:ingredient_list) do
              [
                "8 oz Pineapple Juice",
                "4 Sliced Apples",
                "3 Layers of Wedding Cake"
              ]
            end

            it "persists the recipe with line items" do
              expect(subject).to be_success
              result_value = subject.value!
              recipe = result_value.recipe
              expect(recipe.name).to eq("Super Cheeseburger")
              expect(recipe.url).to eq("https://www.example.com/parsed/result")
              expect(recipe.line_items.map(&:raw_text)).to contain_exactly(
                "8 oz Pineapple Juice",
                "4 Sliced Apples",
                "3 Layers of Wedding Cake"
              )
            end
          end
        end
      end
    end
  end

  describe "#locals" do
    subject { command.locals }

    context "after #result is called" do
      let(:mock_response) do
        instance_double(
          HTTParty::Response,
          code: 200,
          body: File.read("spec/fixtures/example_ingredients_doc.html")
        )
      end

      before do
        expect(HTTParty).to receive(:get).with(given_url).and_return(mock_response)
        command.result
      end

      it "returns a Hash with the recipe object" do
        expect(subject[:recipe]).to be_instance_of(Recipe)
      end
    end
  end
end
