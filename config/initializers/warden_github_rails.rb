Warden::Manager.serialize_into_session do |user|
  user.to_json
end
Warden::Manager.serialize_from_session do |user|
  user = JSON.parse(user)
  Warden::GitHub::User.new(user["attribs"], user["token"])
end
Warden::GitHub::Rails.setup do |config|
  config.add_scope :admin, redirect_uri:  '/',
                           scope:         'read:org'

  config.default_scope = :admin

end
