# frozen_string_literal: true

class CreateMallTables < ActiveRecord::Migration[8.0]
  def up
    unless table_exists?(:discourse_mall_products)
      create_table :discourse_mall_products, if_not_exists: true do |t|
        t.string  :title, null: false
        t.text    :description
        t.integer :price_cents, null: false, default: 0
        t.string  :currency, null: false, default: "CNY"
        t.integer :status, null: false, default: 0
        t.string  :image_url
        t.integer :image_upload_id
        t.integer :video_upload_id
        t.integer :stock, null: false, default: 999999
        t.timestamps null: false
      end
    end

    unless table_exists?(:discourse_mall_coupons)
      create_table :discourse_mall_coupons, if_not_exists: true do |t|
        t.string  :code, null: false
        t.integer :discount_cents, null: false, default: 0
        t.datetime :starts_at
        t.datetime :ends_at
        t.integer :status, null: false, default: 0
        t.timestamps null: false
      end
      add_index :discourse_mall_coupons, :code, unique: true unless index_exists?(:discourse_mall_coupons, :code)
    end

    unless table_exists?(:discourse_mall_orders)
      create_table :discourse_mall_orders, if_not_exists: true do |t|
        t.integer :user_id
        t.string  :sn, null: false
        t.integer :status, null: false, default: 0
        t.integer :pay_provider, null: false, default: 0
        t.integer :total_cents, null: false, default: 0
        t.string  :currency, null: false, default: "CNY"
        t.string  :consignee
        t.string  :phone
        t.string  :country
        t.string  :state
        t.string  :city
        t.string  :address
        t.string  :postcode
        t.string  :ship_company
        t.string  :ship_billno
        t.timestamps null: false
      end
      add_index :discourse_mall_orders, :user_id unless index_exists?(:discourse_mall_orders, :user_id)
      add_index :discourse_mall_orders, :status unless index_exists?(:discourse_mall_orders, :status)
      add_index :discourse_mall_orders, :sn, unique: true unless index_exists?(:discourse_mall_orders, :sn)
    end
  end

  def down
    drop_table :discourse_mall_orders, if_exists: true
    drop_table :discourse_mall_coupons, if_exists: true
    drop_table :discourse_mall_products, if_exists: true
  end
end
