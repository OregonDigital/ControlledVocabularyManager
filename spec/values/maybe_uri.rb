require 'rails_helper'

RSpec.describe MaybeURI do
  let(:valid_uri) {"http://example.com"}
  let(:invalid_uri) {"http:example.com"}

  describe "#value" do
    it "should convert a string if it looks like a URI" do
      expect(MaybeURI.new(valid_uri).value).to eql(RDF::URI(valid_uri))
    end

    it "should leave a string alone if it doesn't look like a URI" do
      expect(MaybeURI.new(invalid_uri).value).to eql(invalid_uri)
    end

    it "shouldn't convert non-strings" do
      fake = double("fake")
      allow(fake).to receive(:to_s).and_return(valid_uri)
      expect(MaybeURI.new(fake.to_s).value).to eql(RDF::URI(valid_uri))

      # Sanity check
      expect(MaybeURI.new(fake).value).to eql(fake)
    end
  end
end
