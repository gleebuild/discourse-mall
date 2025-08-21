
# frozen_string_literal: true
# name: discourse-mall
# about: Full-featured mall (products, coupons, orders) with SSR pages and pluggable payment providers
# version: 0.1.0
# authors: ChatGPT
# url: https://lebanx.com
# required_version: 3.0.0

enabled_site_setting :mall_enabled
register_asset 'stylesheets/common/mall.scss'

after_initialize do
  module ::DiscourseMall
    PLUGIN_NAME = "discourse-mall"
    LOG_DIR  = "/var/www/discourse/public"
    LOG_FILE = File.join(LOG_DIR, "mall.txt")
    def self.log!(msg)
      begin
        FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
        File.open(LOG_FILE, "a") { |f| f.puts("#{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')} | [mall] #{msg}") }
      rescue => e
        Rails.logger.warn("[mall] log error: #{e.class}: #{e.message}")
      end
    end

    class Payment
      # Generic payment callout; real gateways should be provided by sub-plugins
      def self.pay!(order, provider, return_url: nil, notify_url: nil)
        DiscourseMall.log!("pay! provider=#{provider} order=#{order.sn} amount=#{order.total_cents}")
        payload = {
          sn: order.sn,
          amount: order.total_cents,
          currency: order.currency,
          subject: "Order \#{order.sn}",
          return_url: return_url,
          notify_url: notify_url
        }
        # Emit an ActiveSupport notification so sub-plugins can hook
        ActiveSupport::Notifications.instrument("mall.payment.request", provider: provider, order: order, payload: payload)
        # Default fallback: return a placeholder URL (so pages可跳转)
        { ok: true, provider: provider, pay_url: "/mall/order/\#{order.sn}/complete?mock=1" }
      end
    end
  end

  require_relative "app/models/discourse_mall/product"
  require_relative "app/models/discourse_mall/variant"
  require_relative "app/models/discourse_mall/coupon"
  require_relative "app/models/discourse_mall/order"

  require_relative "app/controllers/discourse_mall/public_controller"
  require_relative "app/controllers/discourse_mall/admin_controller"
  require_relative "lib/discourse_mall/engine"

  prefix = SiteSetting.mall_route_prefix.presence || "mall"

  DiscourseMall.log!("booting prefix=/#{prefix}")

  Discourse::Application.routes.prepend do
    get "/#{prefix}" => "discourse_mall/public#index"
    get "/#{prefix}/p/:id" => "discourse_mall/public#show"
    get "/#{prefix}/checkout" => "discourse_mall/public#checkout"
    post "/#{prefix}/orders" => "discourse_mall/public#create_order"
    get "/#{prefix}/order/:sn/complete" => "discourse_mall/public#complete"

    get "/#{prefix}/admin" => "discourse_mall/admin#index", constraints: StaffConstraint.new

    # JSON API
    mount ::DiscourseMall::Engine, at: "/#{prefix}-api"
  end

  # Add a minimal /admin/plugins/mall for discovery (not必须)
  add_admin_route 'mall.admin_title', 'mall'
  Discourse::Application.routes.prepend do
    get '/admin/plugins/mall' => 'admin/plugins#index', constraints: StaffConstraint.new
    get '/admin/plugins/mall.json' => proc { |env| [200, {'Content-Type'=>'application/json'}, ['{}']] }, constraints: StaffConstraint.new
  end

  DiscourseMall.log!("routes ready")
end
