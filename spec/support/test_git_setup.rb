
require 'rugged'

module TestGitSetup
  def setup_git
    unless Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
       Dir.mkdir ControlledVocabularyManager::Application::config.rugged_repo
    end
    repo = Rugged::Repository.init_at(ControlledVocabularyManager::Application::config.rugged_repo)
    oid = repo.write("initial", :blob)
    index = repo.index
    index.add(:path=>"leopard",:oid => oid, :mode =>0100644)
    options = {}
    options[:tree] = index.write_tree(repo)
    options[:author] = {:email => "admin@example.org",:name => 'hayao', :time => Time.now }
    options[:committer] = {:email => "admin@example.org", :name => 'hayao', :time => Time.now }
    options[:message] = "initial commit"
    options[:parents] =  []
    options[:update_ref] = 'HEAD'
    Rugged::Commit.create(repo, options)
    index.write
    options = {}
    options[:strategy] = :force
    repo.checkout_head(options)
    repo.checkout('master')
  end
end
