require 'rails_helper'

RSpec.describe "vocabularies/edit" do

  let(:id) { "Creator" }
  let(:term) { Vocabulary.new(id) }
  before do
    allow(term).to receive(:persisted?).and_return(true)
    assign(:term, term)
    render
  end
  it "should post to /vocabularies/Creator" do
    expect(rendered).to have_selector("form[action='/vocabularies/Creator'][method='post']")
  end
  it "should not have a _method field" do
    expect(rendered).not_to have_selector("input[name='_method']")
  end
  it "should display the term URI" do
    expect(rendered).to have_content(term.rdf_subject.to_s)
  end
  it "has inputs for all editable fields" do
    term.editable_fields.each do |attribute|
      expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
    end
  end
  it "should have an Update Vocabulary button" do
    expect(rendered).to have_button("Update Vocabulary")
  end
end
