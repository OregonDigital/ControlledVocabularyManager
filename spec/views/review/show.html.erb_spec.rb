require 'rails_helper'
require 'support/test_git_setup'

class DummyController < AdminController
    include GitInterface
end

RSpec.describe "review/show" do
  include TestGitSetup

  let(:uri) { "http://opaquenamespace.org/ns/blah" }
  let(:resource) do 
    Term.new(uri).tap do |t|
      t.is_replaced_by = "http://opaquenamespace.org/ns/bla2"
      t.label = ["a_label"] 
    end
  end
  let(:children) {}
  let(:dummy_class) { DummyController.new }

  before do
    assign(:term, resource)
    allow(resource).to receive(:fields).and_return([:label])
  end

  context "when given a vocab" do
    let(:vocabulary) { Vocabulary.new(uri) }
    let(:resource) { TermWithChildren.new(vocabulary, ChildNodeFinder) }
    let(:children) { [] }
    before do
      allow(resource).to receive(:children).and_return(children)
      render
    end
    context "when logged in" do
      let(:user) { User.create(:email => 'blah@blah.com', :name => "George Jones", :password => "admin123",:role => "admin", :institution => "Oregon State University")}
      before do
        sign_in(user) if user
      end
      it "should have a link to mark as reviewed" do
         render
         expect(rendered).to have_link "Mark as reviewed", :href => "/vocabularies/blah/mark"
      end
      it "should have a link to edit the vocabulary" do
        render
        expect(rendered).to have_link "Edit", :href => "/review/blah/edit"
      end
    end
    context "when not logged in" do
      it "should not have a link to create a resource" do
         render
         expect(rendered).to_not have_link "Mark as reviewed", :href => "/vocabularies/blah/mark"
      end
      it "should not have a link to edit the vocabulary" do
        render
        expect(rendered).to_not have_link "Edit", :href => "/review/blah/edit"
      end
    end
  end
   context "when visiting the show page" do
    let(:resource) { 
      t = Term.new(uri) 
      t.is_replaced_by = "http://opaquenamespace.org/ns/bla2"
      t.label = ["a_label", "another_label"]
      t.comment = ["comment"]
      t
    }
    let(:user) { User.create(:email => 'george@blah.com', :name => 'George Smith', :password => "admin123",:role => "admin", :institution => "Oregon State University")}
    it "should display all fields" do
      render
      resource.fields.each do |field|
        expect(rendered).to have_content(field)
      end
    end
    before do
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
      setup_for_review_test(dummy_class)
      allow(resource).to receive(:commit_history).and_return(get_history("blah", "blah_review"))
    end
    after do
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
    it "should display the diff if it exists" do 
      render
      expect(rendered).to have_content("added: <http://www.w3.org/2000/01/rdf-schema#label> \"fooness\" @en .")
    end
  end
end
