require 'test_helper'

class SessionsIntegrationTest < ActionDispatch::IntegrationTest
  test "session expriation" do
    get root_path
    follow_redirect!
    assert_equal login_path, path

    time = Time.now
    Time.stub :now, time do
      post login_path, {
          username: 'admin',
          password: 'Secret1'
      }
      follow_redirect!
      assert_equal admin_root_path, path

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
end
