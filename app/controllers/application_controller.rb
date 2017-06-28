class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :authenticate!, :set_default_format

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
      token = Token.unexpired.find_by(id: token)
      @_current_user = token.user unless token.nil?
    end
  end

  def not_found
    head 404
  end

  def set_default_format
    request.format = :json unless params[:format]
  end
end
