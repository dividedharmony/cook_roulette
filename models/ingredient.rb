# frozen_string_literal: true

require './models/application_record'

class Ingredient < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :recipes, through: :line_items

  validates :name, 
            presence: true,
            uniqueness: { case_sensitive: false }
end
