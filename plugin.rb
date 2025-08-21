# frozen_string_literal: true

# name: discourse-mall
# about: Mall plugin skeleton with admin page and detailed logging
# version: 0.2.0
# authors: LeBanX Assist
# url: https://lebanx.com

enabled_site_setting :mall_enabled

after_initialize do
  module ::Mall
    PLUGIN_NAME ||= "discourse-mall"

    def self.log(msg)
      path = Rails.root.join("public", "mall.txt")
      begin
        File.open(path, "a") { |f| f.puts("#{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")} +0000 | #{msg}") }
      rescue => e
        Rails.logger.warn("[mall] log failed: #{e}")
      end
    end
  end

  Mall.log("[boot] engine ready")

  module ::Mall
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace Mall
    end
  end

  # API engine (mounted at /mall-api)
  ::Mall::Engine.routes.draw do
    get "/ping" => "ping#index"
  end

  Discourse::Application.routes.append do
    mount ::Mall::Engine, at: "/mall-api"

    # SSR front pages
    get "/mall" => "mall/spa#index"
    get "/mall/*path" => "mall/spa#index"

    # Convenience redirect for staff: /mall/admin -> /admin/plugins/mall
    get "/mall/admin" => "mall/spa#admin_redirect"
  end

  # Admin sidebar entry -> /admin/plugins/mall
  add_admin_route "mall.admin_nav_title", "plugins/mall"

  Mall.log("[boot] routes mounted (api:/mall-api, spa:/mall)")
end
