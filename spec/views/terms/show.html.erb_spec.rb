require 'rails_helper'

RSpec.describe "terms/show" do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Term.new(uri) }
  let(:children) {}

  before do
    assign(:term, resource)
    allow(resource).to receive(:fields).and_return([:label, :comment])
    allow(resource).to receive(:get_values).with(anything) { |x| ["#{x}_string"] }
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

  it "should display all fields" do
    resource.fields.each do |field|
      expect(resource).to have_received(:get_values).with(field)
      expect(rendered).to have_content("#{field}_string")
    end
  end
end
