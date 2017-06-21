class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate!

  def authenticate!
    return true if authenticate_token
    render json: { errors: { account: "Unauthorized" } }, status: 401
  end

  def current_user
    @_current_user ||= authenticate_token
  end

  private

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @_current_user = User.find_by_token(token)
    end
  end
end
