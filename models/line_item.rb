# frozen_string_literal: true

require './models/application_record'

class LineItem < ApplicationRecord
  belongs_to :recipe, required: true
  belongs_to :ingredient, required: true

  validates :raw_text, 
            presence: true
end
