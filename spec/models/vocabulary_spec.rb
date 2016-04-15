require 'rails_helper'

RSpec.describe Vocabulary do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Vocabulary.new(uri) }
  let(:resource_with_children) { TermWithChildren.new(resource, ChildNodeFinder) }
  let(:children) { [] }
  

  let(:id) { nil }
  # This test validates the issued/modified behavior
  it "should be a subclass of Term" do
    expect(Vocabulary < Term).to be true
  end
  it "should have a configured type" do
    expect(resource.type).to eq [RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")]
  end

  context "with deprecated children" do
    let(:child) { 
      t = Term.new(uri.to_s+"/banana") 
      t.label = "BananaChild"
      t.is_replaced_by = "test"
      t
    }
    let(:children) { [child] }
    before do
      allow(resource_with_children).to receive(:children).and_return(children)
    end
    it "should should allow vocab deprecate" do
      expect(resource_with_children.allow_vocab_deprecate?).to be true
    end

  end

end
