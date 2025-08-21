
# frozen_string_literal: true
class DiscourseMall::PublicController < ::ApplicationController
  requires_plugin 'discourse-mall'
  skip_before_action :check_xhr
  skip_before_action :redirect_to_login_if_required
  before_action :mall_log

  def index
    @products = DiscourseMall::Product.where(status: 1).order(id: :desc).limit(200)
    render template: 'discourse_mall/public/index', layout: false
  end

  def show
    @product = DiscourseMall::Product.find(params[:id])
    @variants = @product.variants.order(id: :asc)
    render template: 'discourse_mall/public/show', layout: false
  end

  def checkout
    @product = DiscourseMall::Product.find_by(id: params[:product_id])
    @variant = DiscourseMall::Variant.find_by(id: params[:variant_id])
    @qty = params[:qty].to_i > 0 ? params[:qty].to_i : 1
    @coupon_code = params[:coupon].to_s.strip
    base_cents = (@variant&.price_cents || @product&.price_cents || 0) * @qty
    @coupon = DiscourseMall::Coupon.usable.find_by(code: @coupon_code) if @coupon_code.present?
    @pay_cents = @coupon ? @coupon.apply_to(base_cents) : base_cents
    @currency = SiteSetting.mall_currency
    render template: 'discourse_mall/public/checkout', layout: false
  end

  def create_order
    user = current_user || Discourse.system_user
    currency = SiteSetting.mall_currency

    order = DiscourseMall::Order.create!(
      user_id: user.id,
      product_title: params[:product_title],
      variant_title: params[:variant_title],
      qty: params[:qty].to_i,
      total_cents: params[:total_cents].to_i,
      currency: currency,
      recipient: params[:recipient], phone: params[:phone],
      country: params[:country], province: params[:province],
      city: params[:city], address: params[:address], postcode: params[:postcode],
      coupon_code: params[:coupon_code], provider: params[:provider]
    )
    DiscourseMall.log!("order created sn=#{order.sn} provider=#{order.provider} total=#{order.total_cents}")

    result = DiscourseMall::Payment.pay!(order, order.provider, return_url: complete_url(order), notify_url: notify_url(order))

    if result[:ok]
      redirect_to result[:pay_url]
    else
      render plain: "Payment init failed", status: 500
    end
  rescue => e
    DiscourseMall.log!("create_order error: #{e.class}: #{e.message}")
    render plain: "ERROR: #{e.message}", status: 500
  end

  def complete
    @order = DiscourseMall::Order.find_by!(sn: params[:sn])
    if params[:mock] == '1'
      @order.update!(status: :paid)
    end
    render template: 'discourse_mall/public/complete', layout: false
  end

  private

  def complete_url(order); "#{Discourse.base_url}/mall/order/\#{order.sn}/complete"; end
  def notify_url(order);   "#{Discourse.base_url}/mall-api/payment_notify"; end

  def mall_log
    DiscourseMall.log!("#{request.method} #{request.fullpath} uid=#{current_user&.id || 'anon'} ip=#{request.remote_ip}")
  end
end
