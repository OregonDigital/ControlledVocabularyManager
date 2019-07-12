# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IsValidRdfImportUrl do
  describe "#validate" do
    let(:url) { "http://example.com" }
    let(:record) { double("record") }
    let(:errors) { double("errors") }
    let(:validate) { IsValidRdfImportUrl.new.validate(record) }

    before do
      allow(record).to receive(:errors).and_return(errors)
      allow(record).to receive(:url).and_return(url)
    end

    context "when the URL is http" do
      it "should not add errors" do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context "when the URL is https" do
      let(:url) { "https://example.com" }

      it "should not add errors" do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context "when the URL isn't an allowed scheme" do
      let(:url) { "gopher://example.com" }

      it "should add an error" do
        expect(errors).to receive(:add).with(:url, "is not an allowed RDF import URL")
        expect(errors).to receive(:add).with(:base, "URL is not allowed for import.")
        validate
      end
    end

    context "when the URL isn't parseable" do
      let(:url) { "This isn't a URI" }

      it "should add an error" do
        expect(errors).to receive(:add).with(:url, "is not a URL")
        expect(errors).to receive(:add).with(:base, "URL is not valid.")
        validate
      end
    end

    context "when the URL is missing" do
      let(:url) { nil }

      it "should add an error" do
        expect(errors).to receive(:add).with(:url, "can't be blank")
        expect(errors).to receive(:add).with(:base, "URL cannot be blank.")
        validate
      end
    end
  end
end
