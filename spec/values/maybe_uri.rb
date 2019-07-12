# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaybeURI do
  let(:valid_uri) {"http://example.com"}
  let(:invalid_uri) {"http:example.com"}
  let(:should_be_a_string) {"blah blah http://example.com blah"}

  describe "#value" do
    it "should convert a string if it looks like a URI" do
      expect(MaybeURI.new(valid_uri).value).to eql(RDF::URI(valid_uri))
    end

    it "should leave a string alone if it doesn't look like a URI" do
      expect(MaybeURI.new(invalid_uri).value).to eql(invalid_uri)
    end

    it "should not convert non-strings" do
      fake = double("fake")
      allow(fake).to receive(:to_s).and_return(valid_uri)
      expect(MaybeURI.new(fake.to_s).value).to eql(RDF::URI(valid_uri))

      # Sanity check
      expect(MaybeURI.new(fake).value).to eql(fake)
    end
    it "should not convert a uri that has stringy stuff around it" do
      expect(MaybeURI.new(should_be_a_string).value).to eql(should_be_a_string)
    end
  end
end
