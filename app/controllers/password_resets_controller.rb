class PasswordResetsController < ApplicationController
  skip_before_action :authenticate!

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_reset_token
      user.send_password_reset_email
      head 201
    else
      head 404
    end
  end

  def update
  end
end
