require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Server
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    #使用 schema_search_path 或者其他 PostgreSQL 扩展，可以控制如何转储数据库模式
    config.active_record.dump_schemas = :all

    config.cache_store = :dalli_store
    # config.cache_store = :redis_store,  'redis://localhost:6379/0/cache'
    # , {
    #   host: "localhost",
    #   port: 6379,
    #   db: 0,
    #   password: "",
    #   namespace: "cache"
    # }

    config.action_dispatch.rack_cache = {
      metastore: 'redis://localhost:6379/1/metastore',
      entitystore: 'redis://localhost:6379/1/entitystore'
    }

    # 定时任务
    config.active_job.queue_adapter = :sidekiq

    # 配置跨域
    # Avoid CORS issues when API is called from the frontend app.
    # Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.
    # Read more: https://github.com/cyu/rack-cors
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options]
      end
    end
  end
  ENV["DB_USER"] = 'mida'
  ENV["DB_PASSWORD"] = '112420'
  ENV["SECRET_KEY_BASE"] = 'f13760bb00730dca6334207b7339526310205d1891f3007c9c81052e67c241c87e249874f136c3522a8ab8b30398e8ea18ef78ef7c88541a3f44e3da6966asdad69'
end
