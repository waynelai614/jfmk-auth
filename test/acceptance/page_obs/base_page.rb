require 'minitest/rails/capybara'
require 'helpers/custom_matchers'

module Pages
  class Base
    include Capybara::CustomMatchers

    def element_has_focus(id)
      page.evaluate_script("document.activeElement.id") == id
    end

    def send_key_return(css)
      # page.has_css?(css) # Prevents StaleElement errors when trying to call send_keys on a fresh page load... (?)
      page.find(css).native.send_keys(:return)
    end

    protected

    def page
      Capybara.current_session
    end
  end
end
