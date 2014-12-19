require 'rails_helper'

RSpec.describe Vocabulary do
  let(:resource) { Vocabulary.new }
  let(:id) { nil }
  # This test validates the issued/modified behavior
  it "should be a subclass of Term" do
    expect(Vocabulary < Term).to be true
  end
  it "should have a configured type" do
    expect(resource.type).to eq [RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")]
  end
end
