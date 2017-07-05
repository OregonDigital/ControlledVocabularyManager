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
    let(:subj2) { "<http://opaquenamespace.org/ns/blah/zoo>" }
    let(:subj3) { "<http://opaquenamespace.org/ns/blah/shoe>" }
    let(:triple1) { "<http://purl.org/dc/terms/date> \"2016-05-04\" .\n" }
    let(:triple2) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foo\"@en .\n" }
    let(:triple3) { "<http://www.w3.org/2000/01/rdf-schema#label> \"fooness\" @en .\n" }
    let(:triple4) { "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2004/02/skos/core#PersonalName> .\n" }
    let(:triple5) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foobiz\" @en .\n" }
    let(:triple6) { "<http://www.w3.org/2000/01/rdf-schema#label> \"foobuzz\" @en .\n" }

    it "should commit, merge, and provide history" do
      #create blah/foo
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user1)
      dummy_class.rugged_create("blah/foo", subj+triple1+subj+triple2+subj+triple4,"creating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo_review")
      expect(repo.last_commit.message).to include("creating: blah/foo")
      blahfoo_commit = GitCommit.find_by(:term_id=>"blah/foo").unmerged_commits
      expect(blahfoo_commit).to eq(repo.last_commit.oid)

      #review_list
      repo.checkout("master")
      terms = dummy_class.review_list
      expect(terms.first[:id]).to eq("blah/foo")

      #edit_params
      params = dummy_class.edit_params("blah/foo")
      expect(params[:vocabulary][:label].first).to eq("foo")
      #merge blah/foo
      repo.checkout("master")
      branch_commit = dummy_class.rugged_merge("blah/foo")
      expect(repo.last_commit.message).to include("Merge blah/foo_review into master")
      expect(GitCommit.find_by(:term_id=>"blah/foo").merged_commits).to eq(blahfoo_commit + ";")

      #delete branch
      branches = dummy_class.branch_list
      expect(branches).to include("blah/foo_review")
      dummy_class.rugged_delete_branch("blah/foo")
      branches = dummy_class.branch_list
      expect(branches).not_to include("blah/foo_review")

      #create and merge blah/zoo
      dummy_class.rugged_create("blah/zoo", subj2+triple1+subj2+triple5+subj2+triple4,"creating")
      branch_commit2 = dummy_class.rugged_merge("blah/zoo")

      #update blah/foo and merge, switch to Ira
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user2)
      dummy_class.rugged_create("blah/foo", subj+triple1+subj+triple3+subj+triple4, "updating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo_review")
      expect(repo.last_commit.message).to include("updating: blah/foo")
      blahfoo_commit2 = GitCommit.find_by(:term_id=>"blah/foo").unmerged_commit_ids.first
      expect(repo.last_commit.oid).to eq(blahfoo_commit2)

      repo.checkout("master")
      branch_commit = dummy_class.rugged_merge("blah/foo")
      expect(GitCommit.find_by(:term_id=>"blah/foo").merged_commits).to eq("#{blahfoo_commit2};#{blahfoo_commit};")

      #get history of blah/foo
      results = dummy_class.get_history("blah/foo")
      expect(results[0][:author]).to eq("Ira Jones")
      expect(results[0][:diff][0]).to eq("deleted: " + triple2)
      expect(results[0][:diff][1]).to eq("added: " + triple3)

      #rollback blah/zoo, expect fail
      dummy_class.rugged_rollback(branch_commit2)
      expect(repo.last_commit.author[:name]).to eq("Ira Jones")

      #rollback blah/foo, expect success
      dummy_class.rugged_rollback(branch_commit)
      results = dummy_class.get_history("blah/foo")
      expect(results).to be_nil
      expect(repo.last_commit.author[:name]).to eq("George Smith")

      #handle git index locked in merge
      dummy_class.rugged_create("blah/shoe", subj2+triple1+subj2+triple5+subj2+triple4,"creating")
      FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      branch_commit = dummy_class.rugged_merge("blah/shoe")
      expect(branch_commit).to eq(0)
      File.unlink(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      #handle git index locked during create
      FileUtils.touch(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")
      returnval = dummy_class.rugged_create("blah/shoe", subj+triple1+subj+triple2+subj+triple4,"creating")
      expect(returnval).to be false
      File.delete(ControlledVocabularyManager::Application::config.rugged_repo + "/.git/index.lock")

    end
  end
end
