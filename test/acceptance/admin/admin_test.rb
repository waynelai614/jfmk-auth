require "test_helper"
require "acceptance/page_obs/sessions_page"
require "acceptance/page_obs/proxy_page"
require "acceptance/page_obs/admin/admin_page"

class Admin::AdminTest < AcceptanceTest
  before do
    @sessions_page = SessionsPage.new
    @proxy_page = ProxyPage.new
    @admin_page = Admin::AdminPage.new
  end

  test "Admin can login, see links" do
    # Admin user redirected to admin page
    visit root_path
    assert_current_path login_path
    assert @admin_page.has_no_breadcrumb?
    @sessions_page.fill_login 'admin', 'Secret1'
    @sessions_page.click_login_btn

    assert @admin_page.has_no_headline?
    assert @admin_page.has_log_out?('Admin')
    assert @admin_page.has_breadcrumb?([label: 'Admin'])
    assert @admin_page.has_btn_link? 'Manage Users', admin_users_path
    assert @admin_page.has_btn_link? 'View Proxy Site', root_path
  end
end
