
# frozen_string_literal: true
class DiscourseMall::AdminApiController < ::ApplicationController
  requires_plugin 'discourse-mall'
  before_action :ensure_staff

  def create_product
    p = DiscourseMall::Product.create!(
      title: params[:title], description: params[:description],
      image_url: params[:image_url], price_cents: params[:price_cents].to_i,
      stock: params[:stock].to_i, status: 1, currency: SiteSetting.mall_currency
    )
    DiscourseMall.log!("admin create_product id=#{p.id}")
    redirect_to "/mall/admin?tab=products"
  end

  def create_coupon
    c = DiscourseMall::Coupon.new(code: params[:code], voided: false)
    if params[:discount_type] == 'percent'
      c.discount_type = :percent
      c.value_percent = params[:value].to_i
    else
      c.discount_type = :amount
      c.value_cents = params[:value].to_i
    end
    if params[:expires_at].present?
      c.expires_at = Time.parse(params[:expires_at]) rescue nil
    end
    c.save!
    DiscourseMall.log!("admin create_coupon id=#{c.id}")
    redirect_to "/mall/admin?tab=coupons"
  end
end
