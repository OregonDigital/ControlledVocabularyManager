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

  describe "contracts" do
    context "when given Creator" do
      let(:resource) { Vocabulary.new("Creator") }
      it "should have a good rdf_subject" do
        expect(resource.rdf_subject).to eq RDF::URI.new("http://opaquenamespace.org/ns/Creator")
      end
    end
  end
end
