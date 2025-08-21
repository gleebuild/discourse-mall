# frozen_string_literal: true
module DiscourseMall
  class ApiController < ::ApplicationController
    requires_plugin ::DiscourseMall::PLUGIN_NAME
    skip_before_action :verify_authenticity_token

    def ping
      DiscourseMall::Logger.log! "[api] ping"
      render json: { ok: true, via: "mall" }
    end

    # placeholder for payment notify
    def payment_notify
      DiscourseMall::Logger.log! "[api] payment_notify raw=#{request.raw_post.to_s[0..200]}"
      render plain: "OK"
    end
  end
end
