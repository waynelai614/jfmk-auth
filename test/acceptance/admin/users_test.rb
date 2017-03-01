require "test_helper"
require "acceptance/page_obs/sessions_page"
require "acceptance/page_obs/proxy_page"
require "acceptance/page_obs/admin/users_page"

class Admin::UsersTest < AcceptanceTest
  before do
    @sessions_page = SessionsPage.new
    @proxy_page = ProxyPage.new
    @user_page = Admin::UsersPage.new
  end

  test "Admin can login, see users list, view/edit/delete users" do
    # Admin user redirected to admin page
    visit root_path
    assert_current_path login_path
    assert @user_page.has_no_breadcrumb?
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.click_login_btn

    # Verify users list
    assert_current_path admin_users_path
    assert @user_page.has_log_out?('Admin')
    assert @user_page.has_headline?('Users')
    assert @user_page.has_breadcrumb?([{label: 'Admin', link: '/admin'}, {label: 'Users'}])
    assert @user_page.has_user_table_header?
    user_orig_count = User.count
    assert @user_page.has_num_user_records?(User.count)
    User.all.order(created_at: :desc).all.each_with_index do |u, idx|
      assert @user_page.has_user_row_attributes?(u, idx)
    end

    # Add new user
    @user_page.click_new_user
    assert_current_path new_admin_user_path
    assert @user_page.has_headline?('New User')
    assert @user_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'New User'}])

    # Cancel button goes back to users index
    @user_page.click_cancel
    assert_current_path admin_users_path
    assert @user_page.has_users_count?(User.count)

    # Try to add empty user
    @user_page.click_new_user
    assert_current_path new_admin_user_path
    @user_page.click_save
    assert @user_page.has_errors?(
        "3 errors prohibited this user from being saved.",
        [
          "Username can't be blank",
          "Username must be alpha-numeric",
          "Password can't be blank"
        ]
    )

    # Verify errors messages
    assert @user_page.has_input_error?(:username, "Username can't be blank and must be alpha-numeric.")
    assert @user_page.has_input_error?(:password, "Password can't be blank.")
    assert @user_page.has_no_input_error?(:first_name)
    assert @user_page.has_no_input_error?(:last_name)

    # Try to create duplicate username, and bad password
    my_user = {username: 'awesome', password: 'Awesome123', first_name: 'Awesome', last_name: 'Human'}
    @user_page.fill_in :username, 'client'
    @user_page.fill_in :password, 'nope'
    @user_page.fill_in :first_name, my_user[:first_name]
    @user_page.fill_in :last_name, my_user[:last_name]
    @user_page.click_save

    assert @user_page.has_field?(:username, 'client')
    assert @user_page.has_field?(:password, '')
    assert @user_page.has_field?(:first_name, my_user[:first_name])
    assert @user_page.has_field?(:last_name, my_user[:last_name])
    assert @user_page.has_errors?(3)
    assert @user_page.has_input_error?(:username, "Username has already been taken.")
    assert @user_page.has_input_error?(:password, "Password is too short (minimum is 6 characters) " \
      "and must contain at least one uppercase letter, one lowercase letter and one number.")

    # Create valid user and submit
    @user_page.fill_in :username, my_user[:username]
    @user_page.fill_in :password, my_user[:password]
    @user_page.send_key_return

    # Verify new user in the list
    assert_current_path admin_users_path
    assert @user_page.has_num_user_records? user_orig_count + 1
    assert @user_page.has_user_row_attributes?(my_user, 0)

    # Verify can view user
    my_user_id = User.find_by_username(my_user[:username]).id
    @user_page.click_user_action(my_user_id, :view)
    assert_current_path admin_user_path(User.last.id)
    assert @user_page.has_headline?('View User')
    assert @user_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'View User'}])
    assert @user_page.has_field?(:username, my_user[:username], true)
    assert @user_page.has_field?(:password, '', true)
    assert @user_page.has_field?(:first_name, my_user[:first_name], true)
    assert @user_page.has_field?(:last_name, my_user[:last_name], true)
    assert @user_page.has_no_checked_field?(:login_locked, true)
    assert @user_page.has_no_save_btn?
    @user_page.click_back_to_users
    assert_current_path admin_users_path

    # Verify can edit user
    @user_page.click_user_action(my_user_id, :edit)
    assert_current_path edit_admin_user_path(User.last.id)
    assert @user_page.has_headline?('Edit User')
    assert @user_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'Edit User'}])
    assert @user_page.has_field?(:username, my_user[:username])
    assert @user_page.has_field?(:password, my_user[:password])
    assert @user_page.has_field?(:first_name, my_user[:first_name])
    assert @user_page.has_field?(:last_name, my_user[:last_name])
    assert @user_page.has_cancel_btn?

    # Change name
    my_user2 = my_user.dup
    my_user2[:first_name] = "#{my_user[:first_name]}2"
    my_user2[:last_name] = "#{my_user[:last_name]}2"
    @user_page.fill_in(:first_name, my_user2[:first_name])
    @user_page.fill_in(:last_name, my_user2[:last_name])
    @user_page.click_save

    # Verify name changed in list
    assert @user_page.has_num_user_records? user_orig_count + 1
    assert @user_page.has_user_row_attributes?(my_user2, 0)

    # Verify can log in as user
    @user_page.click_log_out
    @sessions_page.fill_login my_user2[:username], my_user2[:password]
    @sessions_page.click_login_btn
    assert_current_path root_path
    assert @proxy_page.has_proxy_content?

    # Logout
    visit logout_path
    assert_current_path login_path
    assert @sessions_page.has_logout_alert?

    # Login as admin again
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.send_input_enter_key

    # Verify can lock user
    @user_page.click_user_action(my_user_id, :edit)
    @user_page.check :login_locked
    my_user2[:login_locked] = true
    @user_page.click_save

    # Verify login locked
    assert @user_page.has_user_row_attributes?(my_user2, 0)
    @user_page.click_log_out
    @sessions_page.fill_login my_user2[:username], my_user2[:password]
    @sessions_page.send_input_enter_key
    assert @sessions_page.has_lock_alert?
    assert @sessions_page.has_alert_count?(1)

    # Verify can delete user
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.send_input_enter_key
    user_id = User.find_by_username(my_user2[:username]).id
    @user_page.click_user_action(my_user_id, :delete)
    page.accept_confirm("Are you sure you want to delete user '#{my_user2[:username]}'?")
    assert @user_page.has_no_user_row_by_id(user_id)
    assert page.has_no_content? my_user2[:username]
    assert @user_page.has_num_user_records? user_orig_count
  end
end
