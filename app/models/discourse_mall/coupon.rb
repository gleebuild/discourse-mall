# frozen_string_literal: true
module DiscourseMall
  class Coupon < ActiveRecord::Base
    self.table_name = "discourse_mall_coupons"
    enum :discount_type, { amount: 0, percent: 1 }, default: :amount
    validates :code, presence: true, uniqueness: true
  end
end
