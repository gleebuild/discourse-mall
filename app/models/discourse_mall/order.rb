
# frozen_string_literal: true
class DiscourseMall::Order < ActiveRecord::Base
  self.table_name = 'discourse_mall_orders'
  belongs_to :user
  validates :sn, presence: true, uniqueness: true

  enum status: { pending: 0, paid: 1, shipped: 2, completed: 3, cancelled: 9 }

  before_validation :assign_sn, on: :create

  def assign_sn
    self.sn ||= "M" + Time.now.strftime('%Y%m%d') + SecureRandom.hex(3).upcase
  end

  def total_cents
    read_attribute(:total_cents) || 0
  end
end
