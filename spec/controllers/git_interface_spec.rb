require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

class DummyController < AdminController
    include GitInterface
end
RSpec.describe GitInterface do
  include TestGitSetup
  let(:user1) { User.create(:email => 'george@blah.com', :password => "admin123",:role => "admin")}
  let(:user2) { User.create(:email => 'ira@blah.com', :password => "admin123",:role => "admin")}
  let(:dummy_class) { DummyController.new }

  before do
    setup_git
  end
  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  describe "git process" do
    it "should commit, merge, and provide history" do
      #commit blah/foo
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user1)
      dummy_class.rugged_create("blah/foo","blahblahblah","creating")
      repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
      repo.checkout("blah/foo")
      expect(repo.last_commit.message).to include("creating: blah/foo")
 
      #merge blah/foo
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user2)
      repo.checkout("master")
      dummy_class.rugged_merge("blah/foo")
      expect(repo.last_commit.message).to include("Merge blah/foo into master")

      #get history of blah/foo
      results = dummy_class.get_history("blah/foo")
      expect(results[:author]).to eq("george")
      expect(results[:reviewer]).to eq("ira")
    end
  end
end
