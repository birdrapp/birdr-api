module AuthHelper
  def sign_in_as(user)
    token = user.tokens.create
    request.headers.merge!({ Authorization: "Token token=#{token}" })
  end

  def send_invalid_token
    request.headers.merge!({ Authorization: "Token token=nope" })
  end
end
