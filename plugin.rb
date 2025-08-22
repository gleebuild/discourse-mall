# frozen_string_literal: true
# name: discourse-mall
# about: Mall plugin skeleton with SSR endpoints and admin-only portal
# version: 0.2.3
# authors: ChatGPT
# url: https://example.com/discourse-mall

enabled_site_setting :mall_enabled

after_initialize do
  module ::DiscourseMall; end

  class ::DiscourseMall::Engine < ::Rails::Engine
    engine_name "discourse_mall"
    isolate_namespace DiscourseMall
  end

  class ::DiscourseMall::MallLogger
    def self.log(event, data = {})
      begin
        path = Rails.root.join("public", "mall.txt")
        line = { at: Time.now.utc.iso8601, ev: event }.merge(data).to_json
        File.open(path, "a") { |f| f.puts(line) }
      rescue => e
        Rails.logger.warn("[mall.log] #{e.class}: #{e.message}")
      end
    end
  end

  class ::DiscourseMall::HomeController < ::ApplicationController
    requires_plugin "discourse-mall"

    before_action :ensure_logged_in, only: [:admin]
    before_action :ensure_mall_admin, only: [:admin]

    def index
      ::DiscourseMall::MallLogger.log("front", { path: request.fullpath, uid: current_user&.id })
      raise Discourse::InvalidAccess unless SiteSetting.mall_enabled

      if params[:plain].present?
        render plain: "SSR OK: #{request.original_fullpath}"
      else
        html = <<~HTML
          <!doctype html>
          <html><head><meta charset="utf-8"><title>Mall</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body{font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; padding: 24px;}
            h1{font-size: 28px;margin-bottom: 8px;}
            code, pre { background: #f5f5f7; padding: 2px 6px; border-radius: 4px; }
            ul{line-height:1.8}
          </style>
          </head>
          <body>
            <h1>Shop Load Test – SSR OK</h1>
            <p>Strategy: <code>server_render</code> &nbsp; Prefix: <code>/mall</code></p>
            <ul>
              <li><a href="/mall/ok">/mall/ok (plain OK)</a></li>
              <li><a href="/mall?plain=1">/mall?plain=1 (plain)</a></li>
              <li><a href="/mall/admin">/mall/admin</a></li>
              <li><a href="/mall-api/ping">/mall-api/ping</a></li>
            </ul>
          </body></html>
        HTML
        render html: html.html_safe
      end
    end

    def ok
      ::DiscourseMall::MallLogger.log("ok", { path: request.fullpath })
      render plain: "OK"
    end

    def admin
      ::DiscourseMall::MallLogger.log("admin", { path: request.fullpath, uid: current_user&.id })
      render html: "<!doctype html><meta charset='utf-8'><h1>Mall Admin – SSR OK</h1><p>Only allowed usernames can see this page.</p>".html_safe
    end

    private

    def ensure_mall_admin
      allowed = SiteSetting.mall_admin_usernames.to_s.downcase.split(",").map(&:strip)
      uname = current_user&.username&.downcase
      raise Discourse::InvalidAccess unless uname && allowed.include?(uname)
    end
  end

  class ::DiscourseMall::ApiController < ::ApplicationController
    requires_plugin "discourse-mall"
    skip_before_action :check_xhr, only: [:ping]
    def ping
      ::DiscourseMall::MallLogger.log("api.ping", { ua: request.user_agent })
      render json: { ok: true, via: "mall" }
    end
  end

  ::DiscourseMall::Engine.routes.draw do
    get "/" => "home#index"
    get "/ok" => "home#ok"
    get "/admin" => "home#admin"
    get "/*path" => "home#index"
  end

  Discourse::Application.routes.prepend do
    mount ::DiscourseMall::Engine, at: "/mall"
    get "/mall-api/ping" => "discourse_mall/api#ping"
  end

  # Expose a flag on the current user so front-end can show an admin link
  add_to_serializer(:current_user, :mall_admin) do
    SiteSetting.mall_enabled &&
      scope.user &&
      SiteSetting.mall_admin_usernames.to_s.downcase.split(",").map(&:strip).include?(scope.user.username.downcase)
  end
end
