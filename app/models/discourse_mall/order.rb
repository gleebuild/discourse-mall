# frozen_string_literal: true
module DiscourseMall
  class Order < ActiveRecord::Base
    self.table_name = "discourse_mall_orders"
    enum :status, { pending: 0, paid: 1, shipped: 2, completed: 3, canceled: 9 }, default: :pending
    belongs_to :user, class_name: "::User"
    validates :sn, presence: true, uniqueness: true

    def paid!
      update!(status: :paid)
    end
  end
end
