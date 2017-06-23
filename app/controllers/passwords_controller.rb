class PasswordsController < ApplicationController
  skip_before_action :authenticate!

  before_action :get_user
  before_action :validate_user, only: :update
  before_action :check_expiration, only: :update

  def create_reset_token
    if @user
      @user.generate_password_reset_token
      @user.send_password_reset_email
      head 201
    else
      head 404
    end
  end

  def update
    if params[:new_password].blank?
      @user.errors.add(:password, "can't be empty")
      render json: { errors: @user.errors.messages }, status: 422
    elsif @user.update_attributes({ password: params[:new_password] })
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

  def validate_user
    unless @user && @user.authenticated?(params[:password_reset_token])
      return head 401
    end
  end

  def check_expiration
    if @user.password_reset_token_expired?
      return head 401
    end
  end
end
