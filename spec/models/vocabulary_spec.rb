require 'rails_helper'

RSpec.describe Vocabulary do
  verify_contract(:vocabulary)
  it_behaves_like "a term" do
    let(:resource_class) { Vocabulary }
  end
  let(:resource) { Vocabulary.new }
  let(:id) { nil }
  # This test validates the issued/modified behavior
  it "should have a configured type" do
    expect(resource.type).to eq [RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")]
  end

  describe "contracts" do
  end
end
