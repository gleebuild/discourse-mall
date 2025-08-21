
# frozen_string_literal: true
class DiscourseMall::Product < ActiveRecord::Base
  self.table_name = 'discourse_mall_products'
  has_many :variants, class_name: 'DiscourseMall::Variant', foreign_key: :product_id, dependent: :destroy

  enum status: { draft: 0, active: 1, archived: 2 }

  validates :title, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  def cover_url
    image_url.presence || SiteSetting.logo_small_url
  end
end
