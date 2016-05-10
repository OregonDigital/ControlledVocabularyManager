require 'rails_helper'

RSpec.describe "terms/show" do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) do 
    Term.new(uri).tap do |t|
      t.is_replaced_by = "http://opaquenamespace.org/ns/bla2"
      t.label = ["a_label"] 
    end
  end
  let(:children) {}

  before do
    assign(:term, resource)
    allow(resource).to receive(:fields).and_return([:label])
    allow(resource).to receive(:persisted?).and_return(true)
  end

  context "when given a vocab" do
    let(:vocabulary) { Vocabulary.new(uri) }
    let(:resource) { TermWithChildren.new(vocabulary, ChildNodeFinder) }
    let(:children) { [] }
    before do
      allow(resource).to receive(:children).and_return(children)
      allow(vocabulary).to receive(:persisted?).and_return(true)
      render
    end
    context "when logged in" do
      let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin")}
      before do
        sign_in(user) if user
      end
      it "should have a link to create a resource" do
         render
         expect(rendered).to have_link "Create Term", :href => "/vocabularies/bla/new"
      end
      it "should have a link to edit the vocabulary" do
        render
        expect(rendered).to have_link "Edit", :href => edit_vocabulary_path(:id => resource.id)
      end
    end
    context "when not logged in" do
      it "should not have a link to create a resource" do
         render
         expect(rendered).to_not have_link "Create Term", :href => "/vocabularies/bla/new"
      end
      it "should not have a link to edit the vocabulary" do
        render
        expect(rendered).to_not have_link "Edit", :href => edit_vocabulary_path(:id => resource.id)
      end
    end
    context "with children" do
      let(:child) { 
        t = Term.new(uri.to_s+"/banana") 
        t.label = "BananaChild"
        t
      }
      let(:children) { [child] }
      it "should have a list of terms in the vocabulary" do
        expect(rendered).to have_content I18n.t("vocabulary.children_header")
        expect(rendered).to have_link child.rdf_subject.to_s
        expect(rendered).to have_content("BananaChild")
      end
    end
  end
  context "when logged in" do
    let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin")}

    before do
      sign_in(user) if user
    end
    it "should have a link to edit the term" do
      render
      expect(rendered).to have_link "Edit", :href => edit_term_path(:id => resource.id)
    end
  end


  context "when term is deprecated" do
    let(:resource) { 
      t = Term.new(uri) 
      t.is_replaced_by = "http://opaquenamespace.org/ns/bla2"
      t
    }
    it "should display deprecated alert" do
      render
      expect(rendered).to have_content "Deprecated"
    end
  end

  context "when not logged in" do
    it "should not have a link to edit the term" do
      render
      expect(rendered).to_not have_link "Edit", :href => edit_term_path(:id => resource.id)
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
    it "should display all fields" do

      render

      resource.fields.each do |field|
        expect(rendered).to have_content(field)
      end

    end
  end
end
