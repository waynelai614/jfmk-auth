require 'test_helper'

class SessionsIntegrationTest < ActionDispatch::IntegrationTest
  test "Admin login session expriation, and no activity email" do
    get root_path
    follow_redirect!
    assert_equal login_path, path

    time = Time.now
    Time.stub :now, time do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post login_path, username: 'admin', password: 'Secret1'
        follow_redirect!
        assert_equal admin_root_path, path
      end

      # get the expected expiry time string
      expected_expiry = (time + 3600).gmtime.strftime("%a, %d %b %Y %H:%M:%S -0000")

      # check the cookie matches this regexp expression containing the
      # expiry time
      assert_match /_jfmk_auth_session=[^;]+; path=\/; expires=#{Regexp.quote(expected_expiry)}; HttpOnly/,
                   headers['Set-Cookie'],
                   "Cookie not with correct expiry time"
    end

    # go forward 30 mins (less than our expiry) and check our session is still valid
    second_request_time = time + 30.minutes
    Time.stub :now, second_request_time do
      get admin_root_path
      assert_response :success
      assert_equal admin_root_path, path
    end

    # go forward 4 hours (less than our expiry) and check our session expires
    second_request_time = time + 4.hours
    Time.stub :now, second_request_time do
      get admin_root_path
      follow_redirect!
      assert_equal login_path, path
    end
  end

  test "User login email" do
    # After user logs in, admin gets an email
    get login_path
    assert_equal login_path, path
    user = users(:client)
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post login_path, username: 'client', password: 'Secret1'
    end
    follow_redirect!
    assert_equal root_path, path
    assert_response :success

    email = ActionMailer::Base.deliveries.last
    assert_equal "[#{request.host}] User Activity: Login for #{user.first_name} #{user.last_name}, @#{user.username}",
                 email.subject
    assert_equal [ENV['ACTION_MAILER_DEFAULT_TO']], email.to
    assert_equal [ENV['ACTION_MAILER_DEFAULT_FROM']], email.from
    content = "Login for #{user.first_name} #{user.last_name}, @#{user.username}"
    assert_match(content, email.html_part.body.to_s)
  end

  test "No demo mode activity email" do
    with_modified_env IS_DEMO_MODE: '1' do
      # After user logs in in demo mode, no email sent
      get login_path
      assert_equal login_path, path
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post login_path, username: 'client', password: 'Secret1'
      end
      follow_redirect!
      assert_equal root_path, path
      assert_response :success
    end
  end
end
