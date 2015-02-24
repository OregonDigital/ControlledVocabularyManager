require 'rails_helper'

RSpec.describe "terms/show" do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Term.new(uri) }
  let(:children) {}

  before do
    assign(:term, resource)
    resource.label = "Blah term"
    resource.comment = "Blah comment"
    resource.persist!
    allow(resource).to receive(:modified).and_call_original
    allow(resource).to receive(:children).and_return(children) if children

    render
  end

  context "when given a vocab" do
    let(:vocabulary) { Vocabulary.new(uri) }
    let(:resource) { TermWithChildren.new(vocabulary) }
    let(:children) { [] }
    it "should have a link to create a resource" do
      expect(rendered).to have_link "Create Term", :href => "/vocabularies/bla/new"
    end
    context "with children" do
      let(:child) { Term.new(uri.to_s+"/banana") }
      let(:children) { [child] }
      it "should have a list of terms in the vocabulary" do
        expect(rendered).to have_content I18n.t("vocabulary.children_header")
        expect(rendered).to have_link child.rdf_subject.to_s
      end
    end
  end

  it "displays the term name" do
    expect(rendered).to have_content("bla")
  end

  it "displays the full URI" do
    expect(rendered).to have_content("http://opaquenamespace.org/ns/bla") 
  end

  it "displays the label" do
    expect(rendered).to have_content("Blah term")
  end

  it "displays a comment" do
    expect(rendered).to have_content("Blah comment")
  end

  it "displays the issued date" do
    expect(rendered).to have_content(Date.today.iso8601)
  end

  it "displays the modified date" do
    expect(resource).to have_received(:modified)
  end
end
