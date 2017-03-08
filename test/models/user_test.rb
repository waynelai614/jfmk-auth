require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context 'validations' do
    # Username validation
    should validate_presence_of :username
    should validate_uniqueness_of :username
    should validate_length_of(:username).is_at_most(32)
    should allow_value('user', 'User', 'USER', 'User1', '1111').for(:username)
    should_not allow_value('user@email.com', '^User', '_user', 'us er').for(:username)
                   .with_message('must be alpha-numeric')

    # Password validation
    should validate_presence_of :password
    should validate_length_of(:password).is_at_least(6).is_at_most(32)
    should allow_value('Password1', 'pAssword1', '1pAssword').for(:password)
    should_not allow_value('password1', 'password', '123456', 'P@ssword1').for(:password)
                   .with_message('must contain at least one uppercase letter, one lowercase letter and one number')

    # First and last name
    should validate_length_of(:first_name).is_at_most(32)
    should validate_length_of(:last_name).is_at_most(32)

    # Password
    should have_secure_password
  end

  context 'authentication' do
    should "lock user after #{User::MAX_LOGIN_ATTEMPTS} login attempts" do
      # Good login
      u = User.authenticate!('client', 'Secret1')
      assert u.is_a?(User)

      # Incrementally lock the account
      User::MAX_LOGIN_ATTEMPTS.times do |idx|
        assert User.authenticate!('client', 'badPassword').nil?
        u.reload # Reload static copy from db
        if idx < User::MAX_LOGIN_ATTEMPTS - 1
          assert_not User.is_login_locked?('client')
        else
          assert User.is_login_locked?('client')
        end
      end

      # User locked, can not login
      assert u.login_locked?
      assert_equal u.login_attempts, User::MAX_LOGIN_ATTEMPTS
      assert User.authenticate!('client', 'Secret1').nil?

      # Unlock user
      u.unlock
      assert_not u.login_locked?
      assert_equal u.login_attempts, 0

      # Good login
      u = User.authenticate!('client', 'Secret1')
      assert u.is_a?(User)
    end

    should 'not allow locked user from logging in' do
      assert User.authenticate!('clientlocked', 'Secret1').nil? # Correct password fails.
      assert User.authenticate!('clientlocked', 'badPassword').nil? # Wrong password fails.
    end

    should 'demo mode should not allow locking' do
      with_modified_env IS_DEMO_MODE: '1' do
        # Good login
        u = User.authenticate!('client', 'Secret1')
        assert u.is_a?(User)

        # No locks
        (User::MAX_LOGIN_ATTEMPTS + 1).times do |idx|
          assert User.authenticate!('client', 'badPassword').nil?
          u.reload # Reload static copy from db
          assert_not User.is_login_locked?('client')
        end
      end
    end
  end
end
