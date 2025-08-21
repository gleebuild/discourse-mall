# frozen_string_literal: true
module DiscourseMall
  class Product < ActiveRecord::Base
    self.table_name = "discourse_mall_products"

    enum :status, { draft: 0, active: 1, archived: 2 }, default: :draft

    has_many :variants, class_name: "DiscourseMall::Variant", foreign_key: :product_id, dependent: :destroy

    validates :title, presence: true
    validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

    def image_url
      if self.image_upload_id.present?
        upload = Upload.find_by(id: self.image_upload_id)
        upload&.url
      else
        self[:image_url] # fallback if set
      end
    end

    def video_url
      if self.video_upload_id.present?
        upload = Upload.find_by(id: self.video_upload_id)
        upload&.url
      end
    end
  end
end
