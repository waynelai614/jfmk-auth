Rails.application.routes.draw do
  root 'proxy#index'

  get 'login', to: 'sessions#index'
  post 'login', to: 'sessions#login'
  get 'logout', to: 'sessions#logout'

  namespace :admin do
    root 'admin#index'
    resources :users
  end

  # TODO: replace this with session based var and use https://github.com/railsware/rack_session_access in test
  if Rails.env.test?
    get '/test_backdoor' => 'test_backdoor#index'
    class TestBackdoorController < ActionController::Base
      def index
        ENV['IS_DEMO_MODE'] = params[:IS_DEMO_MODE] if params[:IS_DEMO_MODE].present?
        render text: 'backdoor success'
      end
    end
  end
end
