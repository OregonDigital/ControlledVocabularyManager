require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

class DummyController < AdminController
    include GitInterface
end
RSpec.describe GitInterface do
  include TestGitSetup
  let(:user1) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin")}
  let(:user2) { User.create(:email => 'ira@blah.com', :name => 'Ira Jones', :password => "admin123",:role => "admin")}
  let(:dummy_class) { DummyController.new }

  before do
    setup_git
  end
  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  describe "git process" do
    let(:subj) { "<http://opaquenamespace.org/ns/blah/foo>" }
    let(:triple1) { "<http://purl.org/dc/terms/date> '2016-05-04' .\n" }
    let(:triple2) { "<http://www.w3.org/2000/01/rdf-schema#label> 'foo' ." }
    let(:triple3) { "<http://www.w3.org/2000/01/rdf-schema#label> 'fooness' ." }

    it "should commit, merge, and provide history" do
      #create blah/foo
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user1)
      dummy_class.rugged_create("blah/foo",subj+triple1+subj+triple2,"creating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo")
      expect(repo.last_commit.message).to include("creating: blah/foo")
 
      #merge blah/foo
      repo.checkout("master")
      dummy_class.rugged_merge("blah/foo")
      expect(repo.last_commit.message).to include("Merge blah/foo into master")

      #update blah/foo and merge
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user2)
      dummy_class.rugged_create("blah/foo", subj+triple1+subj+triple3, "updating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo")
      expect(repo.last_commit.message).to include("updating: blah/foo")

      repo.checkout("master")
      dummy_class.rugged_merge("blah/foo")

      #get history of blah/foo
      results = dummy_class.get_history("blah/foo")
      expect(results[0][:author]).to eq("Ira Jones")
      expect(results[0][:diff][0]).to eq("deleted: " + triple2)
      expect(results[0][:diff][1]).to eq("added: " + triple3)

    end
  end
end
