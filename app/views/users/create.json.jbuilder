if @user.errors.empty?
  json.email @user.email
else
  json.errors @user.errors.as_json
end
