class PasswordResetsController < ApplicationController
  skip_before_action :authenticate!
  before_action :get_user
  before_action :valid_user, only: :update
  before_action :check_expiration, only: :update

  def create
    if @user
      @user.generate_password_reset_token
      @user.send_password_reset_email
      head 201
    else
      head 404
    end
  end

  def update
    if params[:password].empty?
      @user.errors.add(:password, "can't be empty")
      render json: { errors: @user.errors.messages }, status: 422
    elsif @user.update_attributes({ password: params[:password] })
      @user.tokens.destroy_all
      @user.update_attribute(:password_reset_digest, nil)
      head 200
    else
      render json: { errors: @user.errors.messages }, status: 422
    end
  end

  private

  def get_user
    @user = User.find_by(email: params[:email].downcase)
  end

  def valid_user
    unless (@user && @user.authenticated?(params[:id]))
      return head 401
    end
  end

  def check_expiration
    if @user.password_reset_token_expired?
      return head 401
    end
  end
end
