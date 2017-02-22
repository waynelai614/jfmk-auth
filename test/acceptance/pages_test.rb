require "test_helper"
require "acceptance/page_obs/sessions_page"
require "acceptance/page_obs/pages_page"

class PagesTest < AcceptanceTest
  before do
    @sessions_page = SessionsPage.new
    @pages_page = PagesPage.new
  end

  test "Verify homepage" do
    # Root url immediately redirects to login_path because it's a new session
    visit root_path
    @sessions_page.fill_login 'client', 'Secret1'
    @sessions_page.click_login_btn

    assert_current_path root_path
    assert @pages_page.has_nav?
    assert @pages_page.has_log_out?('Client')

    assert @pages_page.has_work_thumb_presigned_image?(0)
    assert @pages_page.click_work_thumb(0)
    assert @pages_page.has_work_detail_video?

    # TODO: How to test reload timeout?
    # If can figure out how to expire rails session, could just call a reload on the page with JS injection.

    # Log out
    @pages_page.click_log_out
    assert_current_path login_path
    assert @sessions_page.has_logout_alert?
  end
end

