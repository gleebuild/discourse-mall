# frozen_string_literal: true

# name: discourse-mall
# about: Simple mall skeleton with SSR "OK" page, admin entry and file logging
# version: 0.2.1
# authors: ChatGPT
# url: https://lebanx.com

enabled_site_setting :mall_enabled

# Admin left nav entry (Plugins -> Mall)
add_admin_route 'mall.admin_nav_title', 'discourse-mall'

after_initialize do
  module ::DiscourseMall
    PLUGIN_NAME = 'discourse-mall'
  end

  require_dependency 'application_controller'

  class ::DiscourseMall::PagesController < ::ApplicationController
    requires_login(false)
    skip_before_action :check_xhr, raise: false

    def index
      write_log('front', request.fullpath)

      if params[:plain].present?
        return render_plain("SSR OK: #{request.fullpath}")
      end

      if request.path.ends_with?('/ok')
        return render_plain('OK')
      end

      html = <<-HTML
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>Mall</title>
          <style>
            body { font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif; margin: 24px; }
            h1 { font-size: 26px; margin-bottom: 6px; }
            p { margin: 4px 0 16px; color: #555; }
            li { margin: 6px 0; }
            code { background: #f6f6f6; padding: 2px 6px; border-radius: 4px; }
          </style>
        </head>
        <body>
          <h1>Shop Load Test – SSR OK</h1>
          <p><strong>Strategy:</strong> ssr_prepend &nbsp; <strong>Prefix:</strong> <code>/mall</code></p>
          <ul>
            <li><a href="/mall/ok">/mall/ok (plain OK)</a></li>
            <li><a href="/mall?plain=1">/mall?plain=1 (plain)</a></li>
            <li><a href="/admin/plugins/discourse-mall">/admin/plugins</a></li>
            <li><a href="/mall-api/ping">/mall-api/ping</a></li>
          </ul>
        </body>
      </html>
      HTML

      render html: html.html_safe
    end

    private

    def write_log(tag, path)
      begin
        fp = Rails.root.join('public', 'mall.txt')
        File.open(fp, 'a') do |f|
          uid = current_user&.id || 0
          ua = request.user_agent.to_s.gsub(/\s+/, ' ')[0,200]
          f.puts("#{Time.now.utc.iso8601} | [#{tag}] GET #{path} uid=#{uid} ua=#{ua}")
        end
      rescue => e
        Rails.logger.warn("discourse-mall log error: #{e}")
      end
    end
  end

  class ::DiscourseMall::ApiController < ::ApplicationController
    requires_login(false)

    def ping
      write_log('api', "ping via=#{request.user_agent}")
      render json: { ok: true, via: 'mall' }
    end

    private

    def write_log(tag, msg)
      begin
        fp = Rails.root.join('public', 'mall.txt')
        File.open(fp, 'a') do |f|
          f.puts("#{Time.now.utc.iso8601} | [#{tag}] #{msg}")
        end
      rescue => e
        Rails.logger.warn("discourse-mall log error: #{e}")
      end
    end
  end

  Discourse::Application.routes.append do
    get '/mall' => 'discourse_mall/pages#index'
    get '/mall/ok' => 'discourse_mall/pages#index'
    get '/mall/admin' => 'discourse_mall/pages#index'
    get '/mall/*path' => 'discourse_mall/pages#index' # ultra-safe catch-all
    get '/mall-api/ping' => 'discourse_mall/api#ping'
  end
end
