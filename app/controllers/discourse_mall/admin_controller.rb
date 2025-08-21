# frozen_string_literal: true
module DiscourseMall
  class AdminController < ::ApplicationController
    requires_plugin ::DiscourseMall::PLUGIN_NAME
    before_action :ensure_logged_in
    before_action :ensure_staff
    before_action :log_request

    layout "application"

    def index
      @products = Product.order(id: :desc).limit(100)
      @coupons  = Coupon.order(id: :desc).limit(100)
      @orders   = Order.order(id: :desc).limit(100)
      render "discourse_mall/admin/index"
    end

    def create_product
      p = params.require(:product).permit(:title, :description, :price_cents, :currency, :stock, :status, :image, :video)
      product = Product.new(
        title: p[:title], description: p[:description],
        price_cents: p[:price_cents].to_i, currency: p[:currency].presence || "CNY",
        stock: (p[:stock].presence || 999999).to_i, status: (p[:status].presence || "active")
      )

      # Handle uploads (image + video) via UploadCreator to keep files on Discourse server
      if (img = p[:image]).present?
        upload = create_upload!(img, content_type: img.content_type)
        product.image_upload_id = upload.id
        product.image_url = upload.url
      end

      if (vid = p[:video]).present?
        upload = create_upload!(vid, content_type: vid.content_type)
        product.video_upload_id = upload.id
      end

      product.save!
      DiscourseMall::Logger.log! "[admin] create_product id=#{product.id} title=#{product.title} image=#{product.image_url} video=#{product.video_url}"
      redirect_to "/mall/admin"
    rescue => e
      DiscourseMall::Logger.log! "[admin] create_product ERROR #{e.class}: #{e.message}"
      render plain: "ERROR: #{e.message}", status: 500
    end

    def create_coupon
      p = params.require(:coupon).permit(:code, :discount_type, :value_cents, :value_percent, :expires_at)
      c = Coupon.new(code: p[:code], discount_type: (p[:discount_type].presence || "amount"))
      c.value_cents   = p[:value_cents].to_i if p[:value_cents].present?
      c.value_percent = p[:value_percent].to_i if p[:value_percent].present?
      c.expires_at    = p[:expires_at].presence
      c.save!
      DiscourseMall::Logger.log! "[admin] create_coupon code=#{c.code} type=#{c.discount_type}"
      redirect_to "/mall/admin"
    rescue => e
      DiscourseMall::Logger.log! "[admin] create_coupon ERROR #{e.class}: #{e.message}"
      render plain: "ERROR: #{e.message}", status: 500
    end

    def ship_order
      p = params.permit(:id, :ship_company, :ship_sn)
      o = Order.find(p[:id])
      o.update!(status: :shipped, ship_company: p[:ship_company], ship_sn: p[:ship_sn])
      DiscourseMall::Logger.log! "[admin] ship_order id=#{o.id} sn=#{o.sn} company=#{o.ship_company} no=#{o.ship_sn}"
      redirect_to "/mall/admin"
    rescue => e
      DiscourseMall::Logger.log! "[admin] ship_order ERROR #{e.class}: #{e.message}"
      render plain: "ERROR: #{e.message}", status: 500
    end

    private

    def create_upload!(file, content_type: nil)
      require_dependency "upload_creator"
      tmp = file.tempfile
      creator = UploadCreator.new(tmp, file.original_filename, content_type: content_type, for_site_setting: false)
      creator.update_file_size
      upload = creator.create_for(current_user.id)
      raise StandardError, "upload failed" unless upload&.persisted?
      upload
    end

    def log_request
      DiscourseMall::Logger.log! "[admin] #{request.method} #{request.path} uid=#{current_user&.id}"
    end
  end
end
