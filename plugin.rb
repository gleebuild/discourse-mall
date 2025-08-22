# frozen_string_literal: true
# name: discourse-mall
# about: Mall plugin skeleton with admin page and detailed logging
# version: 0.1.0
# authors: ChatGPT
# required_version: 3.6.0.beta1
# url: https://lebanx.com

enabled_site_setting :mall_enabled

require_relative "lib/discourse_mall/engine"

after_initialize do
  module ::DiscourseMall
    LOG_FILE = "/var/www/discourse/public/mall.txt"
    def self.log(msg)
      begin
        FileUtils.mkdir_p(File.dirname(LOG_FILE))
        File.open(LOG_FILE, "a") { |f| f.puts("#{Time.now.utc.iso8601} | #{msg}") }
      rescue => e
        Rails.logger.warn("[mall] log fail: #{e}")
      end
      Rails.logger.info("[mall] #{msg}")
    end
  end

  add_admin_route 'mall.admin_nav_title', 'discourse-mall'

  # Serve SSR pages from Rails so they never 404
  Discourse::Application.routes.prepend do
    get "/mall" => "discourse_mall/pages#index"
    get "/mall/admin" => "discourse_mall/pages#index"
    get "/mall/*path" => "discourse_mall/pages#index"
  end
end
