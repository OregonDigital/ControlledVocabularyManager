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
      let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin reviewer editor", :institution => "Oregon State University", :name => "Test")}
      before do
        sign_in(user) if user
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
      context "when logged out" do
        let(:user) { }
        it "should require login" do
          get :index
          expect(response.body).to have_content("Only a user with proper permissions can access")
        end
      end
    end
  end

  describe "GET 'show'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin editor reviewer", :institution => "Oregon State University", :name => "Test")}

      before do
        sign_in(user) if user
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

      context "when logged out" do
        let(:user) { }
        it "should require login" do
          expect(response.body).to have_content("Only a user with proper permissions can access")
        end
      end
      context "term is not under review" do
        it "should handle it gracefully" do
          get :show, :id => "foo"
          expect(response).to redirect_to("/review")
          expect(flash[:notice]).to include("foo could not be found")
        end
      end
    end
  end

  describe "GET 'edit'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin editor reviewer", :institution => "Oregon State University")}

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
      context "term is not under review" do
        it "should handle it gracefully" do
          get :edit, :id => "foo"
          expect(response).to redirect_to("/review")
          expect(flash[:notice]).to include("foo could not be found")
        end
      end
    end
  end

  describe "PATCH 'discard'" do
    context 'when there is an item for review' do
      let(:uri) { "http://opaquenamespace.org/ns/blah" }
      let(:resource) { instance_double("Vocabulary") }
      let(:dummy_class) { DummyController.new }
      let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin editor reviewer", :institution => "Oregon State University")}

      before do
        sign_in(user) if user
        allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
        setup_for_review_test(dummy_class)
        patch :discard, :id => "blah"
      end
      after do
        FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
      end
      it "should work" do
        expect(response).to redirect_to("/review")
        expect(response.body).not_to include("blah")
      end
    end
  end
end
