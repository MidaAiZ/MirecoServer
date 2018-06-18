json.users {
  json.array! @users do |user|
    json.extract! user, :id, :number, :avatar
  end
}
