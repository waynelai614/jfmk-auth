class Admin::UsersController < ApplicationController
  FORM_VIEW = 'admin/users/user_form'.freeze
  DEMO_MSG = 'In demo mode, new users will not be saved, and existing users will not be updated, or deleted.'.freeze

  def index
    @users = User.all.order(created_at: :desc)
    flash.now[:warning] = DEMO_MSG if is_demo_mode?
  end

  def new
    @action = :create
    @user = User.new
    @title = 'New User'
    render FORM_VIEW
  end

  def create
    User.transaction do
      @user = User.create user_params
      raise ActiveRecord::Rollback if is_demo_mode?
    end
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
    User.transaction do
      @user.unlock if @user.login_locked? && user_params[:login_locked] == '0'
      @user.update user_params
      raise ActiveRecord::Rollback if is_demo_mode?
    end
    if @user.valid?
      redirect_to admin_users_path
    else
      # Show errors
      @action = :edit
      render FORM_VIEW
    end
  end

  def destroy
    @user = User.find_by_id params[:id]
    if is_demo_mode? || @user.destroy
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
