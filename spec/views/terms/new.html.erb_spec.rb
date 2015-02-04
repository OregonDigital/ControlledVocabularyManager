require 'rails_helper'

RSpec.describe "terms/new" do
  fake(:vocabulary)
  let(:term) { Term.new }
  before do
    stub(vocabulary).rdf_subject { RDF::URI("http://opaquenamespace.org/ns/#{vocabulary.id}") }
    assign(:vocabulary, vocabulary)
    assign(:term, term)
    render
  end
  it "should post to /terms" do
    expect(rendered).to have_selector("form[action='/terms'][method='post']")
  end
  it "should not have a _method field" do
    expect(rendered).not_to have_selector("input[name='_method']")
  end
  it "should display the vocabulary URI" do
    expect(rendered).to have_content(vocabulary.rdf_subject.to_s)
  end
  it "should have an ID field" do
    expect(rendered).to have_selector("input[name='term[id]']")
  end
  it "should have a vocabulary ID field" do
    expect(rendered).to have_selector("input[type='hidden'][name='vocabulary_id'][value='#{vocabulary.id}']")
  end
  %w{label comment}.each do |attribute|
    it "has inputs for #{attribute}" do
      expect(rendered).to have_selector "input[name='term[#{attribute}][]']"
    end
  end
  it "should have a create term button" do
    expect(rendered).to have_button("Create Term")
  end

  context "with a term in the namespace" do
    let(:term) { Term.new("#{vocabulary.id}/Test") }
    it "should have a properly populated ID field" do
      expect(rendered).to have_field("ID", :with => "Test")
    end
  end
end
