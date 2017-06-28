json.id @sighting.id
json.user do
  json.partial! 'users/user', user: @sighting.user
end
json.bird do
  json.partial! 'birds/bird', bird: @sighting.bird
end
