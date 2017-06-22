json.users {
  json.array! @users do |user|
    json.extract! user, :id, :number
    json.avatar user.avatar.url
  end
}
