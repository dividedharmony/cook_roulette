# frozen_string_literal: true

require './models/application_record'

class Recipe < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :ingredients, through: :line_items

  validates :name, 
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :url,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { 
              with: /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
              message: "must be a valid URL"
            }
end
