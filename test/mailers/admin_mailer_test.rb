require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  test "user activity" do
    user = users(:client)
    request = ActionDispatch::TestRequest.create({})

    # Create the email and store it for further assertions
    now = '2017-03-07 15:26:40 -0800' # Time.zone.now
    email = AdminMailer.activity_email user, request, now

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal [ENV['ACTION_MAILER_DEFAULT_FROM']], email.from
    assert_equal [ENV['ACTION_MAILER_DEFAULT_TO']], email.to
    assert_equal "[#{request.host}] User Activity: Login for #{user.first_name} #{user.last_name}, @#{user.username}",
                 email.subject
    assert_equal read_fixture('activity_email.html').join, email.html_part.body.to_s
    assert_equal read_fixture('activity_email.text').join, email.text_part.body.to_s
  end
end
