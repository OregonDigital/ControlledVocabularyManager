require 'rails_helper'

RSpec.describe "vocabularies/new" do
  let(:vocabulary) { VocabularyInjector.new.term_form }
  before do
    assign(:vocabulary, vocabulary)
    render
  end
  it "has inputs for all editable fields" do
    vocabulary.editable_fields.each do |attribute|
      expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
    end
  end
  it "posts to /vocabularies" do
    expect(rendered).to have_selector("form[action='/vocabularies'][method='post']")
  end
  it "has a create vocabulary button" do
    expect(rendered).to have_button("Create Vocabulary")
  end

  context "when the vocabulary has errors" do
    let(:vocabulary) do
      v = Vocabulary.new
      v.errors.add(:id, "has problems")
      v.errors.add(:label, "has more problems")
      v
    end
    it "should render errors" do
      expect(rendered).to have_content("Please review the problems below")
      expect(rendered).to have_content("has problems")
      expect(rendered).to have_content("has more problems")
    end
  end
end
