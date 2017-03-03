ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/rails/capybara'

# Ensure all migrations applied to test db
ActiveRecord::Migration.check_pending!

class ActiveSupport::TestCase
  # Don't alter fixture loaded data outside of Base page test scope. Only works for non-js driver tests
  self.use_transactional_tests = true

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Minitest reporter
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

  # Climate Control to modify ENV
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

end

# CAPYBARA
# Use container's shell to find the docker ip address
Capybara.app_host = "http://#{ENV['TEST_APP_HOST']}:#{ENV['PORT']}"
Capybara.javascript_driver = :selenium # TODO: add :webkit option for faster tests
Capybara.run_server = false
Capybara.server_port = ENV['PORT']

args = ['--no-default-browser-check', '--start-maximized', '--disable-web-security', '--allow-hidden-media-playback']
caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => args})

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub",
      desired_capabilities: caps
  )
end

class AcceptanceTest < Capybara::Rails::TestCase
  include Capybara::DSL

  # Transations do not work with selenium driver
  self.use_transactional_tests = false

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  before :each do
    Capybara.current_driver = :selenium
    page = Capybara.current_session
  end

  after :each do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def reload!
    page.driver.browser.navigate.refresh
  end
end
