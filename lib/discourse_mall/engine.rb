# frozen_string_literal: true
module ::DiscourseMall; end

class ::DiscourseMall::Engine < ::Rails::Engine
  engine_name "discourse_mall"
  isolate_namespace DiscourseMall

  config.after_initialize do
    Discourse::Application.routes.append do
      mount ::DiscourseMall::Engine, at: "/mall-api"
    end
  end
end

DiscourseMall::Engine.routes.draw do
  get "/ping" => "api#ping"
end
