Rails.application.routes.draw do
  root 'proxy#index'

  get 'login', to: 'sessions#index'
  post 'login', to: 'sessions#login'
  get 'logout', to: 'sessions#logout'

  namespace :admin do
    root 'admin#index'
    resources :users
  end
end
