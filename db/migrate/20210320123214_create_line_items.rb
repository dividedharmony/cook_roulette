# frozen_string_literal: true

class CreateLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table(:line_items) do |t|
      t.references :recipe, foreign_key: true, null: false
      t.references :ingredient, foreign_key: true, null: false
      t.string :raw_text, null: false

      t.timestamps
    end
  end
end
