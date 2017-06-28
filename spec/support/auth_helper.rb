module AuthHelper

  def token_for(user)
    token = user.tokens.first || user.tokens.create
  end

end
