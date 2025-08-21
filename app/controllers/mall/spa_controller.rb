# frozen_string_literal: true
module ::Mall
  class SpaController < ::ApplicationController
    requires_login if SiteSetting.login_required

    skip_before_action :check_xhr, :preload_json

    def index
      ::Mall.log("[front] GET #{request.fullpath} uid=#{current_user&.id || 0}")
      if params[:plain].to_s == "1"
        render plain: "SSR OK: #{request.fullpath}"
      else
        if request.path.ends_with?("/ok")
          render plain: "OK"
        else
          html = <<~HTML
            <!DOCTYPE html>
            <html>
            <head><meta charset="utf-8"><title>Mall</title><meta name="viewport" content="width=device-width, initial-scale=1"></head>
            <body style="font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial; padding: 24px;">
              <h1>Shop – SSR OK</h1>
              <p>如果你能看到这页，说明 /mall SSR 正常。</p>
              <ul>
                <li><a href="/mall/ok">/mall/ok</a></li>
                <li><a href="/mall?plain=1">/mall?plain=1</a></li>
                <li><a href="/mall-api/ping">/mall-api/ping</a></li>
                <li><a href="/admin/plugins/mall">/admin/plugins/mall</a>（仅管理员）</li>
              </ul>
            </body>
            </html>
          HTML
          render html: html.html_safe
        end
      end
    end

    def admin_redirect
      if current_user&.staff?
        ::Mall.log("[admin] redirect /mall/admin -> /admin/plugins/mall uid=#{current_user.id}")
        redirect_to "/admin/plugins/mall"
      else
        ::Mall.log("[admin] deny /mall/admin (not staff) uid=#{current_user&.id || 0}")
        raise Discourse::InvalidAccess
      end
    end
  end
end
