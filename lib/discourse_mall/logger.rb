# frozen_string_literal: true
module ::DiscourseMall
  module Logger
    LOG_DIR  = "/var/www/discourse/public".freeze
    LOG_FILE = File.join(LOG_DIR, "mall.txt").freeze

    def self.log!(message)
      begin
        FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
        ts = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
        File.open(LOG_FILE, "a") { |f| f.puts("#{ts} | #{message}") }
      rescue => e
        Rails.logger.warn("[mall-logger] write error: #{e.class}: #{e.message}")
      end
    end
  end
end
