# frozen_string_literal: true
module DiscourseMall
  class FrontController < ::ApplicationController
    requires_plugin ::DiscourseMall::PLUGIN_NAME
    layout "application"

    before_action :ensure_enabled
    before_action :log_request

    def ok
      DiscourseMall::Logger.log! "[front] ok"
      render plain: "OK"
    end

    def index
      @products = Product.where(status: Product.statuses[:active]).order(id: :desc).limit(60)
      DiscourseMall::Logger.log! "[front] index products=#{@products.size}"
      render "discourse_mall/front/index"
    end

    def show
      @product = Product.find(params[:id])
      DiscourseMall::Logger.log! "[front] show id=#{@product.id}"
      render "discourse_mall/front/show"
    end

    def checkout
      @product = Product.find_by(id: params[:product_id])
      @variant = Variant.find_by(id: params[:variant_id]) if params[:variant_id].present?
      @qty = params[:qty].to_i > 0 ? params[:qty].to_i : 1
      DiscourseMall::Logger.log! "[front] checkout product_id=#{@product&.id} variant_id=#{@variant&.id} qty=#{@qty}"
      render "discourse_mall/front/checkout"
    end

    def create_order
      raise Discourse::InvalidAccess.new unless current_user
      p = params.require(:order).permit(:product_id, :variant_id, :qty, :receiver, :phone, :country, :province, :city, :address, :postcode, :provider, :coupon_code)
      product = Product.find(p[:product_id])
      qty = p[:qty].to_i > 0 ? p[:qty].to_i : 1
      unit_price = (p[:variant_id].present? ? (Variant.find_by(id: p[:variant_id])&.price_cents || product.price_cents) : product.price_cents)
      total = unit_price * qty

      if (code = p[:coupon_code]).present?
        c = Coupon.where(code: code).where("(expires_at is null) or (expires_at > ?)", Time.now).where(voided: [false, nil]).first
        if c
          if c.discount_type.to_sym == :amount
            total = [0, total - c.value_cents.to_i].max
          else
            total = (total * (100 - c.value_percent.to_i) / 100.0).round
          end
        end
      end

      sn = "M#{Time.now.strftime("%Y%m%d%H%M%S")}#{SecureRandom.hex(3).upcase}"
      order = Order.create!(
        sn: sn, user_id: current_user.id,
        product_title: product.title,
        variant_title: (Variant.find_by(id: p[:variant_id])&.title),
        qty: qty, total_cents: total, currency: (product.currency || "CNY"),
        receiver: p[:receiver], phone: p[:phone], country: p[:country], province: p[:province], city: p[:city],
        address: p[:address], postcode: p[:postcode],
        provider: p[:provider], coupon_code: p[:coupon_code], status: :pending
      )

      DiscourseMall::Logger.log! "[order] create sn=#{order.sn} uid=#{current_user.id} provider=#{order.provider} total=#{order.total_cents}"

      provider = (p[:provider] || "mock")
      if provider == "mock"
        order.paid!
        DiscourseMall::Logger.log! "[order] mock paid sn=#{order.sn}"
        redirect_to "/mall/order/#{order.sn}/complete"
      else
        # Placeholders for wechat/paypal, log and show message.
        DiscourseMall::Logger.log! "[order] provider=#{provider} waiting for gateway sn=#{order.sn}"
        render plain: "支付通道(#{provider})待接入，订单号 #{order.sn} 金额 #{order.total_cents / 100.0} #{order.currency}"
      end
    end

    def complete
      @order = Order.find_by!(sn: params[:sn])
      DiscourseMall::Logger.log! "[front] complete sn=#{@order.sn} status=#{@order.status}"
      render "discourse_mall/front/complete"
    end

    private

    def ensure_enabled
      raise Discourse::InvalidAccess.new unless SiteSetting.mall_enabled
    end

    def log_request
      DiscourseMall::Logger.log! "[front] #{request.method} #{request.path} uid=#{current_user&.id || "anon"}"
    end
  end
end
