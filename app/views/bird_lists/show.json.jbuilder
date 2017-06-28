json.array! @bird_list do |bird_list_item|
  json.bird do
    json.partial! 'birds/bird', bird: bird_list_item.bird
  end
  json.seen bird_list_item.seen?
end
