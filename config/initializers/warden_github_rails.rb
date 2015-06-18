Warden::Manager.serialize_into_session do |user|
  user.to_json
end
Warden::Manager.serialize_from_session do |user|
  user = JSON.parse(user)
  Warden::GitHub::User.new(user["attribs"], user["token"])
end
Warden::GitHub::Rails.setup do |config|
  config.add_scope :admin,
    scope: 'read:org',
    client_id: ENV['CVM_GITHUB_CLIENT_ID'] || ENV['GITHUB_CLIENT_ID'],
    client_secret: ENV['CVM_GITHUB_CLIENT_SECRET'] || ENV['GITHUB_CLIENT_SECRET'],
    redirect_uri: '/login'

  config.default_scope = :admin

end
