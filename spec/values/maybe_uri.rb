# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaybeURI do
  let(:valid_uri) { 'http://example.com' }
  let(:invalid_uri) { 'http:example.com' }
  let(:should_be_a_string) { 'blah blah http://example.com blah' }

  describe '#value' do
    it 'converts a string if it looks like a URI' do
      expect(described_class.new(valid_uri).value).to eql(RDF::URI(valid_uri))
    end

    it "leaves a string alone if it doesn't look like a URI" do
      expect(described_class.new(invalid_uri).value).to eql(invalid_uri)
    end

    it 'does not convert non-strings' do
      fake = double('fake')
      allow(fake).to receive(:to_s).and_return(valid_uri)
      expect(described_class.new(fake.to_s).value).to eql(RDF::URI(valid_uri))

      # Sanity check
      expect(described_class.new(fake).value).to eql(fake)
    end

    it 'does not convert a uri that has stringy stuff around it' do
      expect(described_class.new(should_be_a_string).value).to eql(should_be_a_string)
    end
  end
end
