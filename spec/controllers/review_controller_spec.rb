require 'rails_helper'
require 'support/test_git_setup'

class DummyController < AdminController
    include GitInterface
end

RSpec.describe ReviewController do

  include TestGitSetup

  describe "GET 'index'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin")}

      before do
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
        setup_for_review_test(dummy_class)
      end
      after do
        FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
      end
      context "when things are ok" do
        before do
          get :index
        end
        it "should work" do
          expect(response).to be_success
          expect(response).to render_template "index"
        end
      end
      context "when git index is locked" do
        before do
          lock_git_index
          get :index
        end
        after do
          release_git_index
        end
        it "should handle it gracefully" do
          expect(response).to be_success
          expect(flash[:notice]).to include("Something went wrong")
        end
      end
    end
  end

  describe "GET 'show'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin")}

      before do
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
        setup_for_review_test(dummy_class)
        get :show, :id => "blah"
      end
      after do
        FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
      end
      it "should work" do
        expect(response).to be_success
        expect(response).to render_template "show"
      end

    end
  end

  describe "GET 'edit'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin", :institution => "Oregon State University")}

      before do
        sign_in(user) if user
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
        setup_for_review_test(dummy_class)
        get :edit, :id => "blah"
      end
      after do
        FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
      end
      it "should work" do
        expect(response).to be_success
        expect(response).to render_template "edit"
      end
    end
  end
end
