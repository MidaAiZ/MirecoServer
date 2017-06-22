namespace :setup do
  # 数据迁移
  desc 'Seed the database.'
  task :seed_db do
    on roles(:app) do
      within current_path.to_s do
        with rails_env: :development do
          execute :rake, 'db:migrate'
          execute :rake, 'db:seed'
        end
      end
    end
  end
  # 重启sidekiq
  task :restart_sidekiq do
    on roles(:worker) do
      execute :service, "sidekiq restart"
    end
  end
  # after "deploy:published", "restart_sidekiq"

  # 上传一个文件到服务器中
  desc 'upload rails.conf to shared dir'
  task :upload_nginx do
    on roles(:app) do
      #   upload! StringIO.new(File.read('config/rails.conf')), "#{shared_path}/config/nginx.conf"
    end
  end

  # 查看生产环境的日志
  desc 'tailf production log'
  task :production_log do
    on roles(:app) do
      execute "tail -f #{current_path}/log/production.log"
    end
  end

  # 固定的分支才能部署
  desc 'Makes sure local git is in sync with remote.'
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/deploy`
      puts 'WARNING: HEAD is not the same as origin/develop'
      puts 'Run `git push` to sync changes.'
      exit
    end
  end
  # before :deploy, "setup:check_revision"

end
