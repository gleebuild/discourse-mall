# frozen_string_literal: true
module DiscourseMall
  class Variant < ActiveRecord::Base
    self.table_name = "discourse_mall_variants"
    belongs_to :product, class_name: "DiscourseMall::Product"
    validates :title, presence: true
    validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  end
end
