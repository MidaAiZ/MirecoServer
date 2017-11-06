Rails.application.routes.draw do
  # OPTIONS请求
  match 'controller', to: 'controller#action', via: [:options]
  resources :controller

  # 验证码
  # mount RuCaptcha::Engine => '/rucaptcha'

  # API
  get 'api' => 'api#index'

  # 定时任务页面
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  scope module: :index do
    get 'users/search' => 'users#search'
    resources :users do
      collection do
        get 'profile' => 'users#show'
        put 'update' => 'users#update'
        put 'update_phone' => 'users#update_phone'
        put 'update_password' => 'users#update_password'
        post 'check_uniq' => 'users#check_uniq'
      end
    end

    namespace :workspace do # 工作台
      get 'files' => 'center#index'
      get 'articles/published' => 'center#published_articles'
      get 'corpuses/published' => 'center#published_corpuses'
      get 'marked_files' => 'center#marked_files'
      post '/:resource_type/:resource_id/withdraw' => 'center#withdraw'
      get '/:resource_type/:resource_id/editors' => 'center#get_editors'

      resources :articles do
        collection do
          put '/:id/publish' => 'articles#publish'
          put '/:id/move_dir' => 'articles#move_dir'
          post '/:id/add_editor' => 'articles#add_editor'
          post '/:id/remove_editor' => 'articles#remove_editor'
          get '/:id/profile' => 'articles#show_profile'
        end
        resources :history_articles, as: :history
      end

      resources :folders do
        collection do
          put '/:id/move_dir' => 'folders#move_dir'
          post '/:id/add_editor' => 'folders#add_editor'
          post '/:id/remove_editor' => 'folders#remove_editor'
          get '/:id/profile' => 'folders#show_profile'
        end
      end

      resources :corpus do
        collection do
          put '/:id/publish' => 'corpus#publish'
          put '/:id/move_dir' => 'corpus#move_dir'
          post '/:id/add_editor' => 'corpus#add_editor'
          post '/:id/remove_editor' => 'corpus#remove_editor'
          get '/:id/profile' => 'corpus#show_profile'
        end
      end

      # 编辑评论
      post '/:resource_type/:resource_id/edit_comments' => 'edit_comments#create'
      get '/:resource_type/:resource_id/edit_comments' => 'edit_comments#index'
      get '/:resource_type/:resource_id/edit_comments/:id' => 'edit_comments#show'
      post '/:resource_type/:resource_id/edit_comments/:id/replies' => 'edit_comments#add_reply'
      delete '/:resource_type/:resource_id/edit_comments/:id/replies' => 'edit_comments#remove_reply'
      delete '/:resource_type/:resource_id/edit_comments/:id' => 'edit_comments#destroy'

      resources :trashes do
        collection do
          post ':id/recover' => 'trashes#recover'
        end
      end
    end # workspace

    # 主页
    get 'main' => 'main#index'
    get 'articles' => 'main#articles'
    get 'corpuses' => 'main#corpus'
    get 'articles/:id' => 'main#show_article'
    get 'corpuses/:id' => 'main#show_corpus'

    # 点赞
    post '/:resource_type/:resource_id/thumb_ups' => 'thumb_ups#create'
    delete '/:resource_type/:resource_id/thumb_ups' => 'thumb_ups#destroy'

    # 评论
    post '/:resource_type/:resource_id/comments' => 'comments#create'
    get '/:resource_type/:resource_id/comments' => 'comments#index'
    get '/:resource_type/:resource_id/comments/:id' => 'comments#show'
    delete '/:resource_type/:resource_id/comments/:id' => 'comments#destroy'

    # 评论的回复
    post 'comments/:comment_id/replies' => 'comment_replies#create'
    get 'comments/:comment_id/replies' => 'comment_replies#index'
    get 'comments/:comment_id/replies/:id' => 'comment_replies#show'
    delete 'comments/:comment_id/replies/:id' => 'comment_replies#destroy'

    get 'login' => 'session#index'
    post 'login' => 'session#login'
    delete 'logout' => 'session#logout'
    post 'logout' => 'session#logout'

    post 'verify_code' => 'verify#check_code'
    post 'send_msg' => 'verify#send_msg_code'
    post 'verify_msg' => 'verify#check_msg_code'
    get 'verify_email' => 'verify#check_email'
  end

  root 'index/main#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
