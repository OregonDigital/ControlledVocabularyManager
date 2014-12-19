require 'rails_helper'

RSpec.describe "terms/new" do
  let(:id) { "Creator" }
  let(:vocabulary) { Vocabulary.new(id) }
  let(:term) { ControlledVocabulary.new }
  before do
    assign(:vocabulary, vocabulary)
    assign(:term, term)
    render
  end
  it "should display the vocabulary URI" do
    expect(rendered).to have_content(vocabulary.rdf_subject.to_s)
  end
end
