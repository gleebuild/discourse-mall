# frozen_string_literal: true
# name: discourse-mall
# about: Simple Mall plugin (SSR) with uploads and verbose logging
# version: 0.1.0
# authors: ChatGPT
# url: https://lebanx.com/mall

enabled_site_setting :mall_enabled

after_initialize do
  module ::DiscourseMall
    PLUGIN_NAME = "discourse-mall"
  end

  require_relative "lib/discourse_mall/logger"
  require_relative "app/models/discourse_mall/product"
  require_relative "app/models/discourse_mall/variant"
  require_relative "app/models/discourse_mall/coupon"
  require_relative "app/models/discourse_mall/order"
  require_relative "app/controllers/discourse_mall/front_controller"
  require_relative "app/controllers/discourse_mall/admin_controller"
  require_relative "app/controllers/discourse_mall/api_controller"

  DiscourseMall::Logger.log! "[boot] plugin initializing..."

  # Routes
  class ::DiscourseMall::Engine < ::Rails::Engine
    engine_name DiscourseMall::PLUGIN_NAME
    isolate_namespace DiscourseMall
    routes.draw do
      root to: "front#index"
      get  "/ok" => "front#ok"
      get  "/p/:id" => "front#show"
      get  "/checkout" => "front#checkout"
      post "/orders" => "front#create_order"
      get  "/order/:sn/complete" => "front#complete"

      namespace :admin do
        root to: "admin#index"
        post "/products" => "admin#create_product"
        post "/coupons" => "admin#create_coupon"
        post "/orders/:id/ship" => "admin#ship_order"
      end
    end
  end

  # API engine
  class ::DiscourseMall::ApiEngine < ::Rails::Engine
    engine_name "#{DiscourseMall::PLUGIN_NAME}-api"
    isolate_namespace DiscourseMall
    routes.draw do
      get "/ping" => "api#ping"
      post "/payment_notify" => "api#payment_notify"
    end
  end

  Discourse::Application.routes.append do
    mount ::DiscourseMall::Engine, at: "/mall"
    mount ::DiscourseMall::ApiEngine, at: "/mall-api"
  end

  # Add top-right nav entries (client-side) to navigate to mall/admin
  # This uses the legacy widget API; simple and reliable.
  register_asset "javascripts/discourse/initializers/mall-nav.js", :client
end
