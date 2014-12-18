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
end
