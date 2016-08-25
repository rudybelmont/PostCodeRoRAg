PostCodeApp::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  namespace :api do
    namespace :v1 do
      resources :postcodes, only: [:search, :check, :select, :statistics, :stream_all] do
        collection do
          post 'search'
          post 'check'
          post 'select'
          get 'statistics'
          get 'stream_all'
        end
      end

      resources :suburbs, only: [:list] do
        collection do
          get 'list'
        end
      end

      resources :states, only: [:list] do
        collection do
          get 'list'
        end
      end
    end
  end
end
