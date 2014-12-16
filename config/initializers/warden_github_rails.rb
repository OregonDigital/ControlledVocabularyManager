Warden::GitHub::Rails.setup do |config|
  config.add_scope :admin, redirect_uri:  '/',
                           scope:         'read:org'

  config.default_scope = :admin

end
