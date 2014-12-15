require 'rails_helper'

RSpec.describe ControlledVocabulary do
  it "should be an AT::Resource" do
    expect(ControlledVocabulary < ActiveTriples::Resource).to be true
  end
  it "should instantiate" do
    expect{ControlledVocabulary.new}.not_to raise_error
  end
  it "should have the default repository configured" do
    expect(described_class.repository).to eq :default
  end
  context "when it is persisted" do
    let(:uri) { "http://opaquenamespace.org/ns/bla" }
    let(:resource) { ControlledVocabulary.new(uri) }
    before do
      resource.comment = "This is a comment"
      resource.persist!
    end
    it "should be retrievable" do
      expect(ControlledVocabulary.new(uri)).not_to be_empty
    end
  end
end
