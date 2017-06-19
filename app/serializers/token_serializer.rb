class TokenSerializer < ActiveModel::Serializer
  attributes :token

  def token
    object.id
  end
end
