module Test
  class BackdoorController < ActionController::Base
    ENV_VARS = [:IS_DEMO_MODE, :SESSION_EXPIRES_SECONDS].freeze

    def index
      ENV_VARS.each { |key| ENV[key.to_s] = params[key] if params[key].present? }
      render text: 'backdoor success'
    end

    def self.load_routes
      Rails.application.routes.draw do
        namespace :test do
          get '/backdoor' => 'backdoor#index'
        end
      end
    end
  end
end
