
# frozen_string_literal: true
class CreateMallTables < ActiveRecord::Migration[7.0]
  def up
    create_table :discourse_mall_products unless table_exists?(:discourse_mall_products)
    change_table :discourse_mall_products do |t|
      t.string :title, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: 'CNY'
      t.integer :status, null: false, default: 0
      t.string :image_url
      t.integer :stock, null: false, default: 999999
      t.timestamps null: false
    end if column_exists?(:discourse_mall_products, :title) == false

    create_table :discourse_mall_variants unless table_exists?(:discourse_mall_variants)
    change_table :discourse_mall_variants do |t|
      t.integer :product_id, null: false
      t.string :title, null: false
      t.integer :price_cents, null: false, default: 0
      t.timestamps null: false
    end if column_exists?(:discourse_mall_variants, :title) == false
    add_index :discourse_mall_variants, :product_id unless index_exists?(:discourse_mall_variants, :product_id)

    create_table :discourse_mall_coupons unless table_exists?(:discourse_mall_coupons)
    change_table :discourse_mall_coupons do |t|
      t.string :code, null: false
      t.integer :discount_type, null: false, default: 0
      t.integer :value_cents
      t.integer :value_percent
      t.datetime :expires_at
      t.boolean :voided, null: false, default: false
      t.timestamps null: false
    end if column_exists?(:discourse_mall_coupons, :code) == false
    add_index :discourse_mall_coupons, :code, unique: true unless index_exists?(:discourse_mall_coupons, :code)

    create_table :discourse_mall_orders unless table_exists?(:discourse_mall_orders)
    change_table :discourse_mall_orders do |t|
      t.string :sn, null: false
      t.integer :user_id
      t.string :product_title
      t.string :variant_title
      t.integer :qty, default: 1
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: 'CNY'
      t.string :recipient
      t.string :phone
      t.string :country
      t.string :province
      t.string :city
      t.string :address
      t.string :postcode
      t.string :coupon_code
      t.string :provider
      t.integer :status, null: false, default: 0
      t.string :express_company
      t.string :express_no
      t.timestamps null: false
    end if column_exists?(:discourse_mall_orders, :sn) == false
    add_index :discourse_mall_orders, :user_id unless index_exists?(:discourse_mall_orders, :user_id)
    add_index :discourse_mall_orders, :status unless index_exists?(:discourse_mall_orders, :status)
    add_index :discourse_mall_orders, :sn, unique: true unless index_exists?(:discourse_mall_orders, :sn)
  end

  def down
    drop_table :discourse_mall_orders if table_exists?(:discourse_mall_orders)
    drop_table :discourse_mall_coupons if table_exists?(:discourse_mall_coupons)
    drop_table :discourse_mall_variants if table_exists?(:discourse_mall_variants)
    drop_table :discourse_mall_products if table_exists?(:discourse_mall_products)
  end
end
