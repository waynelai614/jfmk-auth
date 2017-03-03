require "test_helper"
require "acceptance/page_obs/sessions_page"
require "acceptance/page_obs/proxy_page"
require "acceptance/page_obs/admin/users_page"

class Admin::UsersTest < AcceptanceTest
  before do
    @sessions_page = SessionsPage.new
    @proxy_page = ProxyPage.new
    @users_page = Admin::UsersPage.new
  end

  test "Admin can login, see users list, view/edit/delete users" do
    # Admin user redirected to admin page
    visit root_path
    assert_current_path login_path
    assert @users_page.has_no_breadcrumb?
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.click_login_btn

    # Visit manage users page
    @users_page.click_btn_link 'Manage Users'
    assert_current_path admin_users_path

    # Verify users list
    assert @users_page.has_log_out?('Admin')
    assert @users_page.has_headline?('Users')
    assert @users_page.has_breadcrumb?([{label: 'Admin', link: '/admin'}, {label: 'Users'}])
    assert @users_page.has_user_table_header?
    user_orig_count = User.count
    assert @users_page.has_users_count?(User.count)
    User.all.order(created_at: :desc).all.each_with_index do |u, idx|
      assert @users_page.has_user_row_attributes?(u, idx)
    end
    assert @users_page.has_no_demo_mode_flash?

    # Add new user
    @users_page.click_new_user
    assert_current_path new_admin_user_path
    assert @users_page.has_headline?('New User')
    assert @users_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'New User'}])

    # Cancel button goes back to users index
    @users_page.click_cancel
    assert_current_path admin_users_path
    assert @users_page.has_users_count?(User.count)

    # Try to add empty user
    @users_page.click_new_user
    assert_current_path new_admin_user_path
    @users_page.click_save
    assert @users_page.has_errors?(
        "3 errors prohibited this user from being saved.",
        [
          "Username can't be blank",
          "Username must be alpha-numeric",
          "Password can't be blank"
        ]
    )

    # Verify errors messages
    assert @users_page.has_input_error?(:username, "Username can't be blank and must be alpha-numeric.")
    assert @users_page.has_input_error?(:password, "Password can't be blank.")
    assert @users_page.has_no_input_error?(:first_name)
    assert @users_page.has_no_input_error?(:last_name)

    # Try to create duplicate username, and bad password
    my_user = {username: 'awesome', password: 'Awesome123', first_name: 'Awesome', last_name: 'Human'}
    @users_page.fill_in :username, 'client'
    @users_page.fill_in :password, 'nope'
    @users_page.fill_in :first_name, my_user[:first_name]
    @users_page.fill_in :last_name, my_user[:last_name]
    @users_page.click_save

    assert @users_page.has_field?(:username, 'client')
    assert @users_page.has_field?(:password, '')
    assert @users_page.has_field?(:first_name, my_user[:first_name])
    assert @users_page.has_field?(:last_name, my_user[:last_name])
    assert @users_page.has_errors?(3)
    assert @users_page.has_input_error?(:username, "Username has already been taken.")
    assert @users_page.has_input_error?(:password, "Password is too short (minimum is 6 characters) " \
      "and must contain at least one uppercase letter, one lowercase letter and one number.")

    # Create valid user and submit
    @users_page.fill_in :username, my_user[:username]
    @users_page.fill_in :password, my_user[:password]
    @users_page.send_key_return

    # Verify new user in the list
    assert_current_path admin_users_path
    assert @users_page.has_users_count? user_orig_count + 1
    assert @users_page.has_user_row_attributes?(my_user, 0)

    # Verify can view user
    my_user_id = User.find_by_username(my_user[:username]).id
    @users_page.click_user_action(my_user_id, :view)
    assert_current_path admin_user_path(User.last.id)
    assert @users_page.has_headline?('View User')
    assert @users_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'View User'}])
    assert @users_page.has_field?(:username, my_user[:username], true)
    assert @users_page.has_field?(:password, '', true)
    assert @users_page.has_field?(:first_name, my_user[:first_name], true)
    assert @users_page.has_field?(:last_name, my_user[:last_name], true)
    assert @users_page.has_no_checked_field?(:login_locked, true)
    assert @users_page.has_no_save_btn?
    @users_page.click_back_to_users
    assert_current_path admin_users_path

    # Verify can edit user
    @users_page.click_user_action(my_user_id, :edit)
    assert_current_path edit_admin_user_path(User.last.id)
    assert @users_page.has_headline?('Edit User')
    assert @users_page.has_breadcrumb?(
        [{label: 'Admin', link: '/admin'}, {label: 'Users', link: '/admin/users'}, {label: 'Edit User'}])
    assert @users_page.has_field?(:username, my_user[:username])
    assert @users_page.has_field?(:password, my_user[:password])
    assert @users_page.has_field?(:first_name, my_user[:first_name])
    assert @users_page.has_field?(:last_name, my_user[:last_name])
    assert @users_page.has_cancel_btn?

    # Change name
    my_user2 = my_user.dup
    my_user2[:first_name] = "#{my_user[:first_name]}2"
    my_user2[:last_name] = "#{my_user[:last_name]}2"
    @users_page.fill_in(:first_name, my_user2[:first_name])
    @users_page.fill_in(:last_name, my_user2[:last_name])
    @users_page.click_save

    # Verify name changed in list
    assert @users_page.has_users_count? user_orig_count + 1
    assert @users_page.has_user_row_attributes?(my_user2, 0)

    # Verify can log in as user
    @users_page.click_log_out
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

    # Visit manage users page
    @users_page.click_btn_link 'Manage Users'
    assert_current_path admin_users_path

    # Verify can lock user
    @users_page.click_user_action(my_user_id, :edit)
    @users_page.check :login_locked
    my_user2[:login_locked] = true
    @users_page.click_save

    # Verify login locked
    assert @users_page.has_user_row_attributes?(my_user2, 0)
    @users_page.click_log_out
    @sessions_page.fill_login my_user2[:username], my_user2[:password]
    @sessions_page.send_input_enter_key
    assert @sessions_page.has_lock_alert?
    assert @sessions_page.has_alert_count?(1)

    # Verify can delete user
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.send_input_enter_key
    @users_page.click_btn_link 'Manage Users'
    assert_current_path admin_users_path
    my_user2_id = User.find_by_username(my_user2[:username]).id
    @users_page.click_user_action(my_user2_id, :delete)
    page.accept_confirm("Are you sure you want to delete user '#{my_user2[:username]}'?")
    assert @users_page.has_no_user_row_by_id(my_user2_id)
    assert page.has_no_content? my_user2[:username]
    assert @users_page.has_users_count? user_orig_count
  end

  describe "Demo Mode" do
    before do
      def set_demo_mode(val)
        visit "#{root_path}test_backdoor/?IS_DEMO_MODE=#{val}"
        assert page.has_content? 'backdoor success'
      end
      set_demo_mode '1'
    end

    test "Admin cannot create/edit/destroy any users" do
      visit root_path

      # Admin login
      @sessions_page.fill_login 'admin', 'Secret1'
      @sessions_page.click_login_btn

      # Admin root page
      assert_current_path admin_root_path
      assert @users_page.has_no_demo_mode_flash?
      @users_page.click_btn_link('Manage Users')

      # Users page
      assert_current_path admin_users_path
      assert @users_page.has_demo_mode_flash?
      orig_count = User.count
      assert @users_page.has_users_count?(orig_count)

      # New user validates, but does not save
      @users_page.click_new_user
      assert_current_path new_admin_user_path
      assert @users_page.has_no_demo_mode_flash?
      @users_page.fill_in(:username, 'client')
      @users_page.fill_in(:password, 'Secret1')
      @users_page.send_key_return
      assert @users_page.has_errors?(1)
      assert @users_page.has_input_error?(:username, "Username has already been taken")
      @users_page.fill_in(:username, 'client2')
      @users_page.fill_in(:password, 'Secret1')
      @users_page.send_key_return

      # No client2 listed on index page
      assert_current_path admin_users_path
      assert @users_page.has_users_count?(orig_count)
      assert page.has_no_content?('client2')

      # Edit user
      my_user = User.find_by_username('admin')
      @users_page.click_user_action(my_user.id, :edit)

      # Edit user validates, but does not save
      assert_current_path edit_admin_user_path(my_user.id)
      assert @users_page.has_no_demo_mode_flash?
      @users_page.fill_in(:username, 'bad username')
      @users_page.send_key_return
      assert @users_page.has_errors?(1)
      assert @users_page.has_input_error?(:username, "Username must be alpha-numeric")
      @users_page.fill_in(:username, 'adminedit')
      @users_page.send_key_return

      # Back to users index, admin has same username
      assert_current_path admin_users_path
      assert @users_page.has_demo_mode_flash?
      assert @users_page.has_user_row_attributes?(users('admin'), 0)

      # Delete user does not save
      assert @users_page.has_demo_mode_flash?
      @users_page.click_user_action(my_user.id, :delete)
      page.accept_confirm("Are you sure you want to delete user '#{my_user.username}'?")
      assert @users_page.has_users_count?(orig_count)
      assert @users_page.has_user_row_attributes?(users('admin'), 0)
      assert @users_page.has_users_count? orig_count
    end

    after do
      set_demo_mode '0'
    end
  end
end
