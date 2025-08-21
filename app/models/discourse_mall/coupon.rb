
# frozen_string_literal: true
class DiscourseMall::Coupon < ActiveRecord::Base
  self.table_name = 'discourse_mall_coupons'
  enum discount_type: { amount: 0, percent: 1 }
  validates :code, presence: true, uniqueness: true

  scope :usable, -> { where(voided: false).where('expires_at IS NULL OR expires_at > ?', Time.now) }

  def apply_to(cents)
    return cents if voided
    case discount_type
    when 'amount'
      [cents - (value_cents || 0), 0].max
    when 'percent'
      v = (value_percent || 0).clamp(0, 100)
      ((cents * (100 - v)) / 100.0).round
    else
      cents
    end
  end
end
