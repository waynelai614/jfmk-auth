Rails.application.routes.draw do
  root 'pages#index'

  get 'login', to: 'sessions#index'
  post 'login', to: 'sessions#login'
  get 'logout', to: 'sessions#logout'

  get 'admin', to: redirect('admin/users')

  namespace :admin do
    resources :users
  end
end
