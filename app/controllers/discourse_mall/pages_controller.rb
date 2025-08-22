# frozen_string_literal: true
module DiscourseMall
  class PagesController < ::ApplicationController
    requires_plugin 'discourse-mall'
    skip_before_action :check_xhr

    def index
      path = request.fullpath
      ::DiscourseMall.log("front SSR index path=#{path} uid=#{current_user&.id || 0}")
      if params[:plain].to_s == "1"
        render plain: "SSR OK: #{path}"
      else
        render :index
      end
    end
  end
end
