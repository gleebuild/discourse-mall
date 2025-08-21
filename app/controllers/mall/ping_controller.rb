# frozen_string_literal: true
module ::Mall
  class PingController < ::ApplicationController
    skip_before_action :check_xhr, :preload_json

    def index
      ::Mall.log("[api] ping via=#{request.user_agent}")
      render json: { ok: true, via: "mall" }
    end
  end
end
