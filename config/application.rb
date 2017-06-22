require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Server
  class Application < Rails::Application
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

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.cache_store = :redis_store,  'redis://localhost:6379/0/cache'
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
    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :head, :options]
      end
    end
  end
end
