module Admin::UsersHelper
  def user_attributes
    ['username', 'first_name', 'last_name', 'admin', 'login_locked', 'login_attempts']
  end
end
