require 'rails_helper'

RSpec.describe "vocabularies/new" do
  let(:vocabulary) { Vocabulary.new }
  before do
    assign(:vocabulary, vocabulary)
    render
  end
  it "displays a form for the given vocabulary" do
    %w{label comment}.each do |attribute|
      expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
    end
  end
  it "posts to /vocabularies" do
    expect(rendered).to have_selector("form[action='/vocabularies'][method='post']")
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
    context "and the vocabulary is not a new record" do
      let(:vocabulary) do
        v = Vocabulary.new
        v.errors.add(:id, "has problems")
        v.errors.add(:label, "has more problems")
        allow(v).to receive(:persisted?).and_return(true)
        v
      end
      it "should still post to /vocabularies" do
        expect(rendered).to have_selector("form[action='/vocabularies'][method='post']")
        expect(rendered).not_to have_selector("input[name='_method'][value='post']")
      end
      it "should say create vocabulary" do
        expect(rendered).to have_button("Create Vocabulary")
      end
    end
  end
end
