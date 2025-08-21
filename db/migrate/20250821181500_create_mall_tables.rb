# frozen_string_literal: true
class CreateDiscourseMallTables < ActiveRecord::Migration[7.0]
  def up
    unless table_exists?(:discourse_mall_products)
      create_table :discourse_mall_products do |t|
        t.string  :title, null: false
        t.text    :description
        t.integer :price_cents, null: false, default: 0
        t.string  :currency, null: false, default: "CNY"
        t.integer :status, null: false, default: 0
        t.string  :image_url
        t.integer :image_upload_id
        t.integer :video_upload_id
        t.integer :stock, null: false, default: 999_999
        t.timestamps
      end
      add_index :discourse_mall_products, :status
    end

    unless table_exists?(:discourse_mall_variants)
      create_table :discourse_mall_variants do |t|
        t.integer :product_id, null: false
        t.string  :title, null: false
        t.integer :price_cents
        t.timestamps
      end
      add_index :discourse_mall_variants, :product_id
    end

    unless table_exists?(:discourse_mall_coupons)
      create_table :discourse_mall_coupons do |t|
        t.string  :code, null: false
        t.integer :discount_type, null: false, default: 0  # 0 amount, 1 percent
        t.integer :value_cents
        t.integer :value_percent
        t.datetime :expires_at
        t.boolean :voided, default: false
        t.timestamps
      end
      add_index :discourse_mall_coupons, :code, unique: true
    end

    unless table_exists?(:discourse_mall_orders)
      create_table :discourse_mall_orders do |t|
        t.string :sn, null: false
        t.integer :user_id, null: false
        t.string :product_title
        t.string :variant_title
        t.integer :qty, null: false, default: 1
        t.integer :total_cents, null: false, default: 0
        t.string  :currency, null: false, default: "CNY"
        t.string :receiver
        t.string :phone
        t.string :country
        t.string :province
        t.string :city
        t.string :address
        t.string :postcode
        t.string :provider
        t.string :coupon_code
        t.integer :status, null: false, default: 0
        t.string :ship_company
        t.string :ship_sn
        t.timestamps
      end
      add_index :discourse_mall_orders, :sn, unique: true
      add_index :discourse_mall_orders, :user_id
      add_index :discourse_mall_orders, :status
    end
  end

  def down
    drop_table :discourse_mall_orders if table_exists?(:discourse_mall_orders)
    drop_table :discourse_mall_coupons if table_exists?(:discourse_mall_coupons)
    drop_table :discourse_mall_variants if table_exists?(:discourse_mall_variants)
    drop_table :discourse_mall_products if table_exists?(:discourse_mall_products)
  end
end
