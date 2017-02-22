class Admin::UsersController < ApplicationController
  FORM_VIEW = 'admin/users/user_form'.freeze

  def index
    @users = User.all.order(created_at: :desc)
  end

  def new
    @action = :create
    @user = User.new
    @title = 'New User'
    render FORM_VIEW
  end

  def create
    @user = User.create user_params
    if @user.valid?
      redirect_to admin_users_path
    else
      # Show errors
      @action = :create
      render FORM_VIEW
    end
  end

  def show
    @user = User.find_by_id params[:id]
    @action = :show
    @title = 'View User'
    render FORM_VIEW
  end

  def edit
    @user = User.find_by_id params[:id]
    @action = :update
    @title = 'Edit User'
    render FORM_VIEW
  end

  def update
    @user = User.find_by_id params[:id]
    if @user.update user_params
      redirect_to admin_users_path
    else
      # Show errors
      @action = :edit
      render FORM_VIEW
    end
  end

  def destroy
    @user = User.find_by_id params[:id]
    if @user.destroy
      redirect_to admin_users_path, info: "User '#{@user.username}' was successfully deleted."
    else
      redirect_to admin_users_path, alert: "Error deleting user #{@user.username}."
    end
  end

  private

  def user_params
    params[:user].permit(:username, :password, :first_name, :last_name, :login_locked)
  end
end
