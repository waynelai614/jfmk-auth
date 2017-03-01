require "test_helper"
require "acceptance/page_obs/sessions_page"
require "acceptance/page_obs/proxy_page"

class ProxyTest < AcceptanceTest
  before do
    @sessions_page = SessionsPage.new
    @proxy_page = ProxyPage.new
  end

  test "Verify homepage" do
    # Root url immediately redirects to login_path because it's a new session
    visit root_path
    @sessions_page.fill_login 'client', 'Secret1'
    @sessions_page.click_login_btn

    assert_current_path root_path
    assert @proxy_page.has_proxy_content?
    assert @proxy_page.has_log_out?('Client')

    assert @proxy_page.has_work_thumb_presigned_image?(0)
    assert @proxy_page.click_work_thumb(0)
    assert @proxy_page.has_work_detail_video?

    # TODO: How to test reload timeout?
    # If can figure out how to expire rails session, could just call a reload on the page with JS injection.

    # Log out
    @proxy_page.click_log_out
    assert_current_path login_path
    assert @sessions_page.has_logout_alert?
  end
end

