require 'rails_helper'

RSpec.describe ImportForm do
  let(:url) { "" }
  let(:preview) { "0" }
  let(:opts) do
    {:url => url, :preview => preview}
  end
  let(:form) { ImportForm.new(opts) }

  describe "validations" do
    context "when the URL is http" do
      let(:url) { "http://example.com" }

      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL is https" do
      let(:url) { "https://example.com" }

      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL isn't an allowed scheme" do
      let(:url) { "gopher://example.com" }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["is not an allowed RDF import URL"]
      end
    end

    context "when the URL isn't parseable" do
      let(:url) { "This isn't a URI" }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["is not a URL"]
      end
    end

    context "when the URL is missing" do
      let(:url) { nil }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["can't be blank"]
      end
    end

    context "when the graph can't be built from the URL" do
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
