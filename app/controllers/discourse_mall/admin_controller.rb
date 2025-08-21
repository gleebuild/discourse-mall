
# frozen_string_literal: true
class DiscourseMall::AdminController < ::ApplicationController
  requires_plugin 'discourse-mall'
  before_action :ensure_staff
  skip_before_action :check_xhr
  before_action :mall_log

  def index
    @tab = params[:tab].presence || 'products'
    case @tab
    when 'products'
      @products = DiscourseMall::Product.order(id: :desc).limit(200)
    when 'coupons'
      @coupons = DiscourseMall::Coupon.order(id: :desc).limit(200)
    when 'orders'
      @orders = DiscourseMall::Order.order(id: :desc).limit(200)
    end
    render template: 'discourse_mall/admin/index', layout: false
  end

  def mall_log
    DiscourseMall.log!("admin #{request.method} #{request.fullpath} uid=#{current_user&.id}")
  end
end
