module AuthHelper

  def sign_in
    sign_in_as valid_user
  end

  def auth_headers(user)
    token = user.tokens.first || user.tokens.create
    { Authorization: "Bearer #{token}" }
  end

  private

  def valid_user
    @valid_user ||= FactoryGirl.create :user
  end

end
