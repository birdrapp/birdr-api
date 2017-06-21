class UsersController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    @user = User.new user_params

    if @user.save
      render json: @user, status: 201
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def show
    render json: current_user
  end

  def destroy
    current_user.destroy
  end

  def update
    if current_user.update_attributes(user_params_without_password)
      render json: current_user
    else
      render json: { errors: current_user.errors }, status: 422
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end

  def user_params_without_password
    user_params.except :password
  end
end
