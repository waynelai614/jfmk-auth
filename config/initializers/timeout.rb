Rack::Timeout.timeout = ENV.fetch('REQUEST_TIMEOUT') { 5 }.to_i
Rack::Timeout.unregister_state_change_observer(:logger) if Rails.env.development? # Less noise in output

