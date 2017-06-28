class UsersController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    @user = User.new user_params

    if @user.save
      render status: 201
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def show
    @user = current_user
    render status: 200
  end

  def destroy
    current_user.destroy
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params_without_password)
      render status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end

  def user_params_without_password
    user_params.except :password, :email
  end
end
