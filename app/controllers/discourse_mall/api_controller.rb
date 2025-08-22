# frozen_string_literal: true
module DiscourseMall
  class ApiController < ::ApplicationController
    requires_plugin 'discourse-mall'
    skip_before_action :check_xhr

    def ping
      ::DiscourseMall.log("api ping via=#{request.user_agent}")
      render json: { ok: true, via: "mall" }
    end
  end
end
