require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProductSearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

#日本時間になるように修正
#config.time_zone = 'Asia/Tokyo'
#config.active_record.default_timezone = :local
#config.i18n.default_locale = :ja
#I18n.config.available_locales = :ja
#I18n.default_locale = :ja

#config.i18n.available_locales = ["en", "ja"]
#config.i18n.default_locale = :ja