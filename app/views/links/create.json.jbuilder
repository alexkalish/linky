if @link.errors.empty?
  json.partial! 'links/link', link: @link
else
  json.errors @link.errors.as_json
end
