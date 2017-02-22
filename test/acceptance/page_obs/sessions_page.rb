require "acceptance/page_obs/base_page"

class SessionsPage < Pages::Base
  CSS_LOGIN_BTN = "#login".freeze

  def submit_disabled?
    page.has_button?(id: 'login', disabled: true)
  end

  def submit_enabled?
    page.has_button?(id: 'login', disabled: false)
  end

  def fill_login(username, password = nil)
    page.fill_in(id: 'username', with: username) if username.present?
    page.fill_in(id: 'password', with: password) if password.present?
  end

  def has_login_alert?
    page.has_css?('.alert', count: 1, text: 'Invalid username or password.')
  end

  def has_lock_alert?
    page.has_css?('.alert', count: 1, text: 'Username is locked.')
  end

  def has_logout_alert?
    page.has_css?('.alert', count: 1, text: 'You have been logged out.')
  end

  def has_alert_count?(count)
    if count == 0
      page.has_no_css?('.alert')
    else
      page.has_css?('.alert', count: count)
    end
  end

  def dismiss_alert
    page.find('.alert .close').click
    raise 'Log In alert did not go away!' unless has_alert_count?(0)
    true
  end

  def click_login_btn
    unless submit_enabled?
      raise "Expected login buton to be enabled, but it is not."
    end
    page.find("#login").click # Disabled check helps wait for JS to load
  end

  def send_input_enter_key
    unless submit_enabled?
      raise "Expected login buton to be enabled, but it is not."
    end
    send_key_return("#login")
  end

  def has_username_input?(username = '')
    page.has_field?('Username', with: username)
  end

  def has_password_input?
    page.has_field?('Password')
  end

  def has_no_password?
    page.has_field?('Password', with: '')
  end
end
