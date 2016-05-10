namespace :admin_user do
  task :create do
    User.create(:email => "admin@opaquenamespace.org", :password => "admin123", :institution => "University of Oregon", :role => "admin")
  end
end
