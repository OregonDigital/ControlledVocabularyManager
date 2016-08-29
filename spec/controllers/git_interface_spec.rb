require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'
require 'thread'

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
    let(:subj2) { "<http://opaquenamespace.org/ns/blah/zoo>" }
    let(:triple1) { "<http://purl.org/dc/terms/date> \"2016-05-04\" .\n" }
    let(:triple2) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foo\"@en .\n" }
    let(:triple3) { "<http://www.w3.org/2000/01/rdf-schema#label> \"fooness\" @en .\n" }
    let(:triple4) { "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2004/02/skos/core#PersonalName> .\n" }
    let(:triple5) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foobiz\" @en .\n" }
    let(:triple6) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foobuzz\" @en .\n" }

    it "should commit, merge, and provide history" do
      #create blah/foo
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user1)
      dummy_class.rugged_create("blah/foo", "blah/foo", subj+triple1+subj+triple2+subj+triple4,"creating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo")
      expect(repo.last_commit.message).to include("creating: blah/foo")

      #review_list
      repo.checkout("master")
      terms = dummy_class.review_list
      expect(terms.first[:branch]).to eq("blah/foo")

      #edit_params
      params = dummy_class.edit_params("blah/foo")
      expect(params[:vocabulary][:label].first).to eq("foo")

      #merge blah/foo
      lockedrepo = GitInterface::LockedRepo.instance
      lockedrepo.repo.checkout("master")
      dummy_class.rugged_merge(lockedrepo.repo, "blah/foo", "blah/foo")
      expect(lockedrepo.repo.last_commit.message).to include("Merge blah/foo into master")

      #delete branch
      branches = dummy_class.branch_list
      expect(branches).to include("blah/foo")
      dummy_class.rugged_delete_branch(lockedrepo.repo, "blah/foo")
      branches = dummy_class.branch_list
      expect(branches).not_to include("blah/foo")

      #create and merge blah/zoo
      dummy_class.rugged_create("blah/zoo", "blah/zoo", subj2+triple1+subj2+triple5+subj2+triple4,"creating")
      branch_commit2 = dummy_class.rugged_merge(lockedrepo.repo, "blah/zoo", "blah/zoo")

      #update blah/foo and merge, switch to Ira
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user2)
      dummy_class.rugged_create("blah/foo", "blah/foo", subj+triple1+subj+triple3+subj+triple4, "updating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo")
      expect(repo.last_commit.message).to include("updating: blah/foo")
      lockedrepo.repo.checkout("master")
      branch_commit = dummy_class.rugged_merge(lockedrepo.repo, "blah/foo", "blah/foo")

      #get history of blah/foo
      results = dummy_class.get_history("blah/foo")
      expect(results[0][:author]).to eq("Ira Jones")
      expect(results[0][:diff][0]).to eq("deleted: " + triple2)
      expect(results[0][:diff][1]).to eq("added: " + triple3)

      #rollback blah/zoo, expect fail
      dummy_class.rugged_rollback(lockedrepo.repo, branch_commit2)
      expect(repo.last_commit.author[:name]).to eq("Ira Jones")

      #rollback blah/foo, expect success
      dummy_class.rugged_rollback(lockedrepo.repo, branch_commit)
      results = dummy_class.get_history("blah/foo")
      expect(results).to be_nil
      expect(repo.last_commit.author[:name]).to eq("George Smith")

      #lock the repo
      t1 = Thread.new{
        lockedrepo = GitInterface::LockedRepo.instance
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user1)
        dummy_class.rugged_create("blah/foo", "blah/foo", subj+triple1+subj+triple5+subj+triple4,"updating")
        branch_commit = dummy_class.rugged_merge(lockedrepo.repo, "blah/foo", "blah/foo")
        b = 0
        for i in 0..100000
          b = b + 1
        end
        dummy_class.rugged_rollback(lockedrepo.repo, branch_commit)
      }
      t2 = Thread.new{
        lockedrepo = GitInterface::LockedRepo.instance
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user2)
        dummy_class.rugged_create("blah/zoo", "blah/zoo", subj2+triple1+subj2+triple6+subj2+triple4,"upadating")
        dummy_class.rugged_merge(lockedrepo.repo, "blah/zoo", "blah/zoo")
      }
      t1.join
      t2.join
      results = dummy_class.get_history("blah/foo")
      expect(results).to be_nil
      expect(repo.last_commit.author[:name]).to eq("Ira Jones")

    end
  end
end
