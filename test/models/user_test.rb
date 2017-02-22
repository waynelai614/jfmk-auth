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
    should 'lock user after N login attempts' do
      # Good login
      u = User.authenticate!('client', 'Secret1')
      assert u.is_a?(User)

      # Incrementally lock the account
      3.times do |idx|
        assert User.authenticate!('client', 'badPassword').nil?
        u.reload # Reload static copy from db
        if idx < 2
          assert_not User.is_login_locked?('client')
        else
          assert User.is_login_locked?('client')
        end
      end

      # Good login won't work
      assert User.authenticate!('client', 'Secret1').nil?

      # Unlock user
      User.find_by_username('client').unlock

      # Good login
      u = User.authenticate!('client', 'Secret1')
      assert u.is_a?(User)
    end

    should 'not allow locked user from logging in' do
      assert User.authenticate!('clientlocked', 'Secret1').nil? # Correct password fails.
      assert User.authenticate!('clientlocked', 'badPassword').nil? # Wrong password fails.
    end
  end
end
