json.token @token.id
json.user do
  json.partial! 'users/user', user: @token.user
end
