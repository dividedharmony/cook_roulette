# frozen_string_literal: true

require './models/application_record'

class LineItem < ApplicationRecord
  validates :raw_text, 
            presence: true
end
