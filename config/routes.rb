
# frozen_string_literal: true
DiscourseMall::Engine.routes.draw do
  post '/admin/products' => 'admin_api#create_product'
  post '/admin/coupons' => 'admin_api#create_coupon'
end
