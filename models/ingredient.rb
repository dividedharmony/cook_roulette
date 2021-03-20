# frozen_string_literal: true

require './models/application_record'

class Ingredient < ApplicationRecord
  validates :name, 
            presence: true,
            uniqueness: { case_sensitive: false }
end
