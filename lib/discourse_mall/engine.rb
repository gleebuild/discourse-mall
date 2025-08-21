
# frozen_string_literal: true
module DiscourseMall
  class Engine < ::Rails::Engine
    engine_name 'discourse_mall'
    isolate_namespace DiscourseMall
  end
end

DiscourseMall::Engine.routes.draw do
  get '/ping' => proc { |env| [200, {'Content-Type'=>'application/json'}, ['{"ok":true,"via":"mall-engine"}']] }
  post '/payment_notify' => proc { |env| [200, {'Content-Type'=>'text/plain'}, ['OK']] }
end
