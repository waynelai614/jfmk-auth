class User < ApplicationRecord
  MAX_LOGIN_ATTEMPTS = 3

  validates :username, presence: true, uniqueness: true, length: {maximum: 32},
            format: {with: /\A[a-zA-Z\d]+\z/, message: 'must be alpha-numeric'}

  has_secure_password
  validates :password, presence: true, length: {minimum: 6, maximum: 32},
            allow_nil: true, # Allows incremental saves/updates without having to require password (has_secure_password)
            format: {
                with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./,
                message: 'must contain at least one uppercase letter, one lowercase letter and one number'
            }

  validates :first_name, length: {maximum: 32}
  validates :last_name, length: {maximum: 32}

  class << self
    def is_login_locked?(username)
      (user = User.find_by_username username).present? && user.login_locked?
    end

    def authenticate!(username, password)
      # Exit if account not found
      return if (user = User.find_by_username username).blank?

      # Exit if account locked
      return if self.is_login_locked?(username)

      # Returns user if credentials authenticate, and reset login_attempts.
      if user.authenticate(password)
        user.update!(login_attempts: 0)
        return user
      elsif ENV['IS_DEMO_MODE'] != '1'
        # Increments .login_attempts and sets .login_locked if exceeds limit.
        user.login_attempts += 1
        if user.login_attempts >= MAX_LOGIN_ATTEMPTS
          user.login_locked = true
        end
        user.save!
       end
      nil
    end
  end

  def unlock
    self.login_locked = false
    self.login_attempts = 0
    self.save!
  end
end
