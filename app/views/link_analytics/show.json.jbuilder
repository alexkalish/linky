if @errors.present?
  json.errors @errors.as_json
else
  json.array! @analytics
end
