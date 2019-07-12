# frozen_string_literal: true

require 'rails_helper'
require 'rdf_loader'

RSpec.describe ImportForm do
  let(:url) { "http://opaquenamespace.org/ns/workType/aibanprints.jsonld" }
  let(:preview) { "0" }
  let(:term_list) { instance_double("ImportableTermList") }
  let(:validators) { instance_double("IsValidRdfImportUrl") }
  let(:rdfimporter) { RdfImporter }
  let(:form) { ImportForm.new(url, preview, rdfimporter) }

  before do
    WebMock.allow_net_connect!
    #RdfLoader.load_url(url)
  end

  describe "#valid?" do
    it "should return the state of errors.empty?" do
      expect(form.errors).to receive(:empty?).and_return(:state)
      expect(form.valid?).to eq(:state)
    end

    it "should call the rdf importer" do
      expect(form).to receive(:run)
      form.valid?
    end
  end

  describe "#term_list" do
    context "when the importer hasn't been run" do
      it "should be nil" do
        expect(form.term_list).to eq(nil)
      end
    end

    context "when the importer has been run" do
      it "should be the importer's `run` result" do
        form.valid?
        expect(form.term_list.size).to be > 0
      end
    end
  end

  describe "#preview?" do
    context "when preview is '1'" do
      let(:preview) { "1" }

      it "should return true" do
        expect(form.preview?).to eq(true)
      end
    end

    context "when preview isn't '1'" do
      it "should return false" do
        ["0", "one", "true", true].each do |val|
          form.preview = val
          expect(form.preview?).to eq(false)
        end
      end
    end
  end
end
