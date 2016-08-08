namespace :git_dev do
  desc "Create and initialize git repository for development"
  task create_dev_repo: :environment do
    if Rails.env != "production" and !Dir.exist? "git_dev"
      Dir.mkdir "git_dev"
      Dir.chdir "git_dev" do
        system ( "git init" )
        system ( "echo 'Development repo for terms' > README.txt" )
        system ( "git add README.txt")
        system ( "git commit -m 'initial commit'" )
      end
    end
  end
end
