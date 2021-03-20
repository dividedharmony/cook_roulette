# frozen_string_literal: true

class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table(:recipes) do |t|
      t.string :url, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
