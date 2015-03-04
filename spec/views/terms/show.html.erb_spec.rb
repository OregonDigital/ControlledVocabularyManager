require 'rails_helper'

RSpec.describe "terms/show" do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Term.new(uri) }
  let(:children) {}

  before do
    assign(:term, resource)
    allow(resource).to receive(:fields).and_return([:label, :comment])
    allow(resource).to receive(:get_values).with(anything) { |x| ["#{x}_string"] }
    allow(resource).to receive(:persisted?).and_return(true)
  end

  context "when given a vocab" do
    let(:vocabulary) { Vocabulary.new(uri) }
    let(:resource) { TermWithChildren.new(vocabulary) }
    let(:children) { [] }
    before do
      allow(resource).to receive(:children).and_return(children)
      allow(vocabulary).to receive(:persisted?).and_return(true)
      render
    end
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
    it "should have a link to edit the vocabulary" do
      expect(rendered).to have_link "Edit", :href => edit_vocabulary_path(:id => resource.id)
    end
  end

  it "should have a link to edit the term" do
    render
    
    expect(rendered).to have_link "Edit", :href => edit_term_path(:id => resource.id)
  end

  it "should display all fields" do
    render

    resource.fields.each do |field|
      expect(resource).to have_received(:get_values).with(field)
      expect(rendered).to have_content("#{field}_string")
    end
  end
end
