source 'https://gems.ruby-china.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.2'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Useful when you need to retrieve fragments for a collection of objects from the cache
gem 'jbuilder_cache_multi'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# 解决前后端分离跨域问题
gem 'rack-cors', :require => 'rack/cors'

# 角色权限管理
gem "rolify"

# 分页插件
gem 'kaminari'

# memcache插件，用于缓存
gem 'dalli'

# 后端处理文件上传的插件
gem 'carrierwave' #github: 'carrierwaveuploader/carrierwave'

# minimagick 是ImageMagick的ruby接口，在图片上传时可以处理图片
gem 'mini_magick'

# 验证码插件
gem 'rucaptcha'

#Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# rest-client,用于产生发送http请求和接受响应
 gem 'rest-client'
 gem 'mime-types'

# 定时器
gem 'sidekiq'
gem 'sidetiq'

# 缓存以及定时器依赖
gem "redis"
gem "redis-rails"
gem 'redis-namespace'
gem 'redis-rack-cache'
gem 'sinatra' # 用于使用自带的监控页面

# Use Unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
