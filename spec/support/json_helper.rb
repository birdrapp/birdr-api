module JsonHelper
  def json
    JSON.parse response.body, symbolize_names: true
  end

  def json_params(hash)
    new_hash = hash.dup
    new_hash.transform_keys! { |key| key.to_s.camelize(:lower) }
    new_hash.to_json
  end
end
