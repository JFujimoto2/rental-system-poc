class UsersController < ApplicationController
  before_action :authorize_user_management!

  def index
    @users = User.order(:role, :name)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "#{@user.name} のロールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :role ])
  end
end
