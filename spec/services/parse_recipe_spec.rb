# frozen_string_literal: true

require './services/parse_recipe'

RSpec.describe ParseRecipe do
  describe ".call" do
    let(:given_url) { "www.example.com" }
    let(:mock_instance) { instance_double(described_class) }

    subject { described_class.call(url: given_url) }

    it "is just a wrapper for #call" do
      expect(described_class).to receive(:new).with("www.example.com").and_return(mock_instance)
      expect(mock_instance).to receive(:call) { "Result from #call" }
      expect(subject).to eq("Result from #call")
    end
  end

  describe "#call" do
    let(:given_url) { "www.allrecipes.com" }
    let(:parser) { described_class.new(given_url) }

    subject { parser.call }

    context "if url is not valid" do
      let(:given_url) { "Not a valid URL" }

      it "fails" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq(
          "We only support allrecipes.com currently. 'Not a valid URL' is not supported."
        )
      end
    end

    context "if url does not go to allrecipes.com" do
      let(:given_url) { "www.example.com" }

      it "fails" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq(
          "We only support allrecipes.com currently. 'www.example.com' is not supported."
        )
      end
    end

    context "if url is valid and goes to allrecipes" do
      let(:given_url) { "https://www.allrecipes.com/recipe/777/example-recipe/" }

      before do
        expect(HTTParty).to receive(:get).with(
          "https://www.allrecipes.com/recipe/777/example-recipe/"
        ).and_return(mock_response)
      end

      context "if query to url is not a 200 response" do
        let(:mock_response) { instance_double(HTTParty::Response, code: 403) }

        it "fails" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq(
            "Response from https://www.allrecipes.com/recipe/777/example-recipe/ was a 403 response."
          )
        end
      end

      context "if query to url is a 200 response" do
        let(:mock_body) { "Fake HTML document" }
        let(:mock_response) { instance_double(HTTParty::Response, code: 200, body: mock_body) }

        context "if response does not parse to an HTML document" do
          before do
            expect(Nokogiri).to receive(:HTML).and_raise("Too fake to handle!")
          end

          it "fails" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq(
              "Could not parse response: Too fake to handle!"
            )
          end
        end

        context "if response parses to an HTML document" do
          context "if title cannot be found" do
            let(:mock_body) do
              File.open("spec/fixtures/example_blank_doc.html").read
            end

            it "fails" do
              expect(subject).not_to be_success
              expect(subject.failure).to eq(
                "Could not find a title for recipe."
              )
            end
          end

          context "if title is blank" do
            let(:mock_body) do
              File.read("spec/fixtures/example_blank_title_doc.html")
            end

            it "fails" do
              expect(subject).not_to be_success
              expect(subject.failure).to eq(
                "Title of recipe was blank or not in expected location."
              )
            end
          end

          context "if title is present" do
            let(:mock_body) do
              File.read("spec/fixtures/example_doc.html")
            end

            it "returns a ParseRecipeResult wrapped in a Success monad" do
              expect(subject).to be_success
              result = subject.value!
              expect(result.given_url).to eq("https://www.allrecipes.com/recipe/777/example-recipe/")
              expect(result.recipe_url).to eq("https://www.allrecipes.com/recipe/777/example-recipe/")
              expect(result.recipe_title).to eq("Cheeseburgers in Paradise")
            end
          end
        end
      end
    end
  end
end
