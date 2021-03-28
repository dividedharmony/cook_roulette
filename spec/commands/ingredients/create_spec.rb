# frozen_string_literal: true

require 'ostruct'
require './commands/ingredients/create'

RSpec.describe Commands::Ingredients::Create do
  describe "#result" do
    let(:params) { Sinatra::IndifferentHash.new }
    let(:request) { instance_double(Sinatra::Request) }
    let(:command) { described_class.new(request, params) }

    subject { command.result }

    context "if line_item_id does not belong to a line_item" do
      before do
        params["line_item_id"] = 999_999_999
      end

      it "returns a Failure monad" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq("Could not find line_item with id 999999999")
      end
    end

    context "if line_item_id does belong to a line_item" do
      let(:recipe) { Recipe.create!(name: "Cool Beans", url: "https://www.example.com/cool-beans") }
      let(:line_item) { LineItem.create!(raw_text: "4 Sliced Apples", recipe: recipe) }

      before do
        params["line_item_id"] = line_item.id
      end

      context "if ingredient_source is new_ingredient" do
        before do
          params["ingredient_source"] = "new-ingredient"
        end

        context "if new ingredient cannot be built" do
          before do
            params["ingredient_name"] = nil
          end

          it "returns a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq("Name can't be blank")
          end
        end

        context "if ingredient can be built" do
          before do
            params["ingredient_name"] = "Apple"
          end

          # context "if line_item and ingredient cannot be associated" do
          #   # I don't know of a non-contrived way of preventing
          #   # a line_item and an ingredient from being associated
          # end

          context "if line_item and ingredient can be associated" do
            it "associates the line_item with the ingredient" do
              expect { subject }.to change { Ingredient.count }.from(0).to(1)
              expect(line_item.reload.ingredient.name).to eq("Apple")
              expect(subject).to be_success
              create_cmd = subject.value!
              expect(create_cmd.success_path).to eq("/recipes/#{recipe.id}")
            end
          end
        end
      end

      context "if ingredient_source is old_ingredient" do
        before do
          params["ingredient_source"] = "old-ingredient"
        end

        context "if ingredient_id does not belong to an ingredient" do
          before do
            params["ingredient_id"] = 987_654_321
          end

          it "returns a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq("Could not find ingredient with id 987654321")
          end
        end

        context "if ingredient_id does belong to an ingredient" do
          let(:ingredient) { Ingredient.create!(name: "Carrot") }

          before do
            params["ingredient_id"] = ingredient.id
          end

          # context "if line_item and ingredient cannot be associated" do
          #   # I don't know of a non-contrived way of preventing
          #   # a line_item and an ingredient from being associated
          # end

          context "if line_item and ingredient can be associated" do
            it "associates the line_item with the ingredient" do
              expect { subject }.not_to change { Ingredient.count }.from(1)
              expect(line_item.reload.ingredient.name).to eq("Carrot")
              expect(subject).to be_success
              create_cmd = subject.value!
              expect(create_cmd.success_path).to eq("/recipes/#{recipe.id}")
            end
          end
        end
      end

      context "if ingredient_source is neither new nor old" do
        before do
          params["ingredient_source"] = "blah blah"
        end

        it "returns a Failure monad" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq("Invalid Ingredient Source Type!")
        end
      end
    end
  end
end
