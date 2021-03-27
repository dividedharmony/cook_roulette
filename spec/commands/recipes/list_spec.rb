# frozen_string_literal: true

require './commands/recipes/list'

RSpec.describe Commands::Recipes::List do
  let(:params) { instance_double(Sinatra::IndifferentHash) }
  let(:request) { instance_double(Sinatra::Request) }
  let(:command) { described_class.new(request, params) }
  let!(:recipe) do
    Recipe.create!(
      name: "Strawberry",
      url: "https://www.example.com/strawberry"
    )
  end

  subject { command.result }
  
  it "lists all recipes" do
    expect(subject).to be_success
    list_value = subject.value!
    expect(list_value.locals[:recipes]).to include(recipe)
  end
end
