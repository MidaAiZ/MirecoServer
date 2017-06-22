source 'https://gems.ruby-china.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
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

# 使用redis作为缓存层
gem "redis"
gem 'redis-rails'
gem 'redis-rack-cache'

# 定时器
gem 'redis-namespace'
gem 'sinatra' # 用于使用自带的监控页面

# Use Unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'
  gem 'capistrano-faster-assets'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
