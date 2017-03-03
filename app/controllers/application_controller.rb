class ApplicationController < ActionController::Base
  SESSION_EXPIRES_AFTER_SECONDS = (ENV.fetch('SESSION_EXPIRES_AFTER_SECONDS'){3600}).to_i

  protect_from_forgery with: :exception
  before_action :set_cache_headers, :login_required, :admin_required

  private

  def login_required
    # User must be logged in to access site
    if session[:user_id]
      @current_user = User.find_by_id session[:user_id]
      return if @current_user
    end
    redirect_to login_path
    false
  end

  def admin_required
    # Non-admin users trying to access /admin prefixed paths are redirected to root
    path = Rails.application.routes.recognize_path request.env['PATH_INFO']
    top_path = "/#{path[:controller].split('/')[0]}"
    if top_path == admin_root_path && !@current_user.admin?
      redirect_to root_path
    end
  end

  def set_cache_headers
    expires_now
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
