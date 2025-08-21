
# frozen_string_literal: true

# name: discourse-mall
# about: Minimal mall scaffold (pages + admin + logging + uploads) for Discourse 3.6
# version: 0.1.3
# authors: ChatGPT
# url: https://example.invalid/discourse-mall
# required_version: 3.5.0

enabled_site_setting :mall_enabled

after_initialize do
  module ::Mall
    MALL_LOG_PATH = Rails.root.join("public", "mall.txt")

    def self.log(tag, msg)
      line = "#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S %z')} | [#{tag}] #{msg}\n"
      begin
        File.open(MALL_LOG_PATH, "a") { |f| f.write(line) }
      rescue => e
        Rails.logger.warn("mall.log_failed: #{e.class}: #{e.message}")
      end
      Rails.logger.info("[mall] #{msg}")
    end
  end

  class ::Mall::Engine < ::Rails::Engine
    engine_name "mall"
    isolate_namespace Mall
  end

  class ::Mall::ApplicationController < ::ApplicationController
    skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, raise: false

    before_action do
      Mall.log("req", "path=#{request.fullpath} uid=#{current_user&.id || 0} ua=#{request.user_agent.to_s[0..80]}")
    end
  end

  class ::Mall::FrontController < ::Mall::ApplicationController
    def ok
      Mall.log("front", "OK ping")
      render plain: "OK"
    end

    def index
      if params[:plain].present?
        Mall.log("ssr", "plain index")
        render plain: "SSR OK: #{request.fullpath}"
      else
        Mall.log("ssr", "html index")
        html = <<~HTML
        <!doctype html>
        <html><head><meta charset="utf-8"><title>Mall – SSR OK</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;padding:28px;}</style>
        </head><body>
          <h1>Shop Load Test – SSR OK</h1>
          <p><b>Strategy:</b> ssr_prepend &nbsp; <b>Prefix:</b> /mall</p>
          <ul>
            <li><a href="/mall/ok">/mall/ok (plain OK)</a></li>
            <li><a href="/mall?plain=1">/mall?plain=1 (plain)</a></li>
            <li><a href="/admin/plugins">/admin/plugins</a></li>
            <li><a href="/mall-api/ping">/mall-api/ping</a></li>
          </ul>
        </body></html>
        HTML
        render html: html.html_safe
      end
    end

    def admin_redirect
      ensure_staff
      Mall.log("front", "redirect admin -> /admin/plugins/mall")
      redirect_to path("/admin/plugins/mall")
    end
  end

  class ::Mall::ApiController < ::Mall::ApplicationController
    requires_login except: [:ping]
    def ping
      Mall.log("api", "ping")
      render json: { ok: true, via: "mall" }
    end

    def upload
      file = params[:file]
      raise Discourse::InvalidParameters.new(:file) unless file

      # UploadCreator expects a tempfile and a filename
      upload = UploadCreator.new(file.tempfile, file.original_filename, origin: "mall").create_for(current_user.id)
      Mall.log("upload", "by=#{current_user.id} id=#{upload.id} sha1=#{upload.sha1} url=#{upload.url}")
      render json: { id: upload.id, url: upload.url, filename: upload.original_filename }
    end
  end

  Mall::Engine.routes.draw do
    get "/" => "front#index"
    get "/ok" => "front#ok"
    get "/admin" => "front#admin_redirect"
  end

  Discourse::Application.routes.prepend do
    mount ::Mall::Engine, at: "/mall"
    get "/mall-api/ping" => "mall/api#ping"
    post "/mall-api/upload" => "mall/api#upload"
  end

  # Add a link under Admin → Plugins
  add_admin_route "mall.admin_nav_title", "mall"
end
