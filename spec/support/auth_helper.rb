module AuthHelper

  def sign_in
    sign_in_as valid_user
  end

  def sign_in_as(user)
    token = user.tokens.first || user.tokens.create
    request.headers.merge!({ Authorization: "Token token=#{token}" })
  end

  private

  def valid_user
    @valid_user ||= FactoryGirl.create :user
  end

end
