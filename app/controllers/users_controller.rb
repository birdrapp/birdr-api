class UsersController < ApplicationController
  skip_before_action :authenticate!

  def create
    @user = User.new user_params

    if @user.save
      render json: @user, status: 201
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
