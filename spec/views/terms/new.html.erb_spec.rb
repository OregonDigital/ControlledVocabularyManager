require 'rails_helper'

RSpec.describe "terms/new" do
  let(:id) { "Creator" }
  let(:vocabulary) { Vocabulary.new(id) }
  let(:term) { Term.new }
  before do
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
    expect(rendered).to have_selector("input[type='hidden'][name='vocabulary_id'][value='#{id}']")
  end
  %w{label comment}.each do |attribute|
    it "has inputs for #{attribute}" do
      expect(rendered).to have_selector "input[name='term[#{attribute}][]']"
    end
  end
  it "should have a create term button" do
    expect(rendered).to have_button("Create Term")
  end
  # The below tests deals with Terms that may already exist but have errors.
  context "when term is persisted" do
    let(:term) do
      t = Term.new
      allow(t).to receive(:persisted?).and_return(true)
      t
    end
    it "should have a create term button" do
      expect(rendered).to have_button("Create Term")
    end
    it "should post to /terms" do
      expect(rendered).to have_selector("form[action='/terms'][method='post']")
    end
    it "should not have a _method field" do
      expect(rendered).not_to have_selector("input[name='_method']")
    end
  end
end
