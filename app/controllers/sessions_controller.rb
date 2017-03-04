class SessionsController < ApplicationController
  before_action :check_logged_in, only: [:index, :login]
  skip_before_action :login_required

  def login
    user = User.authenticate!(params[:username], params[:password])
    if user.present?
      reset_session
      session[:user_id] = user.id

      # Admin goes to admin page, all other users go to root content page
      redirect_to user.admin? ? admin_root_path : root_path
    else
      flash.now[:alert] =
          if User.is_login_locked?(params[:username])
            "Username is locked. Please contact the administrator to reset."
          else
            "Invalid username or password."
          end
      @username = params[:username]
      render :index
    end
  end

  def logout
    reset_session
    flash[:info] = "You have been logged out."
    redirect_to root_path
  end

  private

  # Trying to access login page when already logged in? Redirect to home page
  def check_logged_in
    if session[:user_id]
      redirect_to root_path
      return false
    end
    true
  end
end
