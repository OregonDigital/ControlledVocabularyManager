
require 'rugged'

module TestGitSetup
  include GitInterface
  def setup_git
    if Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
    Dir.mkdir ControlledVocabularyManager::Application::config.rugged_repo
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

  def setup_for_review_test(dummy_class)
    setup_git

    s1 = "<http://opaquenamespace.org/ns/blah<http://www.w3.org/2000/01/rdf-schema#label> \"foo\"@en .\n"
    s2 = "<http://opaquenamespace.org/ns/blah><http://purl.org/dc/terms/date> \"2016-05-04\" .\n"
    s3 = "<http://opaquenamespace.org/ns/blah><http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2004/02/skos/core#PersonalName>"
    s4 = "<http://opaquenamespace.org/ns/blah><http://www.w3.org/2000/01/rdf-schema#label> \"fooness\" @en .\n"
    dummy_class.rugged_create("blah", s1+s2+s3,"creating")
    dummy_class.rugged_merge("blah")
    dummy_class.rugged_create("blah", s4+s2+s3, "updating")
  end

  def setup_for_show_test(dummy_class)
    setup_for_review_test(dummy_class)
    dummy_class.rugged_merge("blah")
  end

end
