# frozen_string_literal: true

# name: discourse-mall
# about: Simple Mall plugin scaffold with SSR pages (/mall, /mall/admin), API (/mall-api/ping), and detailed logging to /var/www/discourse/public/mall.txt
# version: 0.1.4
# authors: ChatGPT
# url: https://example.com/discourse-mall

enabled_site_setting :mall_enabled

after_initialize do
  require "fileutils"

  module ::DiscourseMall
    PLUGIN_NAME = "discourse-mall"
  end

  module ::DiscourseMallLogger
    LOG_DIR  = "/var/www/discourse/public"
    LOG_FILE = File.join(LOG_DIR, "mall.txt")

    def self.log!(message)
      begin
        FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
        timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
        File.open(LOG_FILE, "a") { |f| f.puts("#{timestamp} | #{message}") }
      rescue => e
        Rails.logger.warn("[mall-logger] write error: #{e.class}: #{e.message}")
      end
    end
  end

  class ::DiscourseMall::Engine < ::Rails::Engine
    engine_name "discourse_mall"
    isolate_namespace DiscourseMall
    config.after_initialize do
      ::DiscourseMallLogger.log!("[boot] engine ready")
    end
  end

  # ==== MODELS ====
  class ::DiscourseMall::Product < ActiveRecord::Base
    self.table_name = "discourse_mall_products"
    enum :status, { draft: 0, on_shelf: 1, off_shelf: 2 }, default: :draft
  end

  class ::DiscourseMall::Coupon < ActiveRecord::Base
    self.table_name = "discourse_mall_coupons"
    enum :status, { active: 0, void: 1, expired: 2 }, default: :active
  end

  class ::DiscourseMall::Order < ActiveRecord::Base
    self.table_name = "discourse_mall_orders"
    enum :status, { pending: 0, paid: 1, shipped: 2, done: 3, cancelled: 9 }, default: :pending
    enum :pay_provider, { mock: 0, wechat: 1, paypal: 2 }, default: :mock
  end

  # ==== CONTROLLERS ====
  module ::DiscourseMall
    class FrontController < ::ApplicationController
      requires_plugin ::DiscourseMall::PLUGIN_NAME
      skip_before_action :check_xhr, only: [:index, :admin, :ok]

      def index
        ::DiscourseMallLogger.log!("[front] GET #{request.fullpath} uid=#{current_user&.id}")
        if params[:plain]
          render plain: "SSR OK: #{request.fullpath}"
        else
          html = <<~HTML
            <!doctype html><meta charset="utf-8">
            <title>Shop Load Test – SSR OK</title>
            <h1>Shop Load Test – SSR OK</h1>
            <p><b>Strategy:</b> ssr_prepend &nbsp; <b>Prefix:</b> /mall</p>
            <ul>
              <li><a href="/mall/ok">/mall/ok (plain OK)</a></li>
              <li><a href="/mall?plain=1">/mall?plain=1 (plain)</a></li>
              <li><a href="/admin/plugins">/admin/plugins</a></li>
              <li><a href="/mall-api/ping">/mall-api/ping</a></li>
            </ul>
          HTML
          render html: html.html_safe
        end
      end

      def admin
        guardian.ensure_staff!
        ::DiscourseMallLogger.log!("[admin] GET #{request.fullpath} uid=#{current_user&.id}")
        html = <<~HTML
          <!doctype html><meta charset="utf-8">
          <title>Mall Admin – SSR OK</title>
          <h1>Shop Admin – SSR OK</h1>
          <ul>
            <li><a href="/mall/ok">/mall/ok</a></li>
            <li><a href="/mall?plain=1">/mall?plain=1</a></li>
            <li><a href="/mall-api/ping">/mall-api/ping</a></li>
          </ul>
        HTML
        render html: html.html_safe
      rescue Discourse::InvalidAccess
        render json: { ok: false, err: "forbidden" }, status: 403
      end

      def ok
        render plain: "OK"
      end
    end

    class ApiController < ::ApplicationController
      skip_before_action :check_xhr

      def ping
        ::DiscourseMallLogger.log!("[api] ping via=#{request&.user_agent}")
        render json: { ok: true, via: "mall" }
      end
    end
  end

  # ==== ROUTES ====
  ::DiscourseMall::Engine.routes.draw do
    get "/ping" => "api#ping"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseMall::Engine, at: "/mall-api"

    get "/mall" => "discourse_mall/front#index"
    get "/mall/admin" => "discourse_mall/front#admin"
    get "/mall/ok" => "discourse_mall/front#ok"
  end

  ::DiscourseMallLogger.log!("[boot] routes mounted (api:/mall-api, spa:/mall)")
end
