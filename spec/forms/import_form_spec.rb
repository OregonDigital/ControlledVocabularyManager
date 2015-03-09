require 'rails_helper'

RSpec.describe ImportForm do
  let(:opts) { Hash.new }
  let(:form) { ImportForm.new(opts) }

  describe "validations" do
    context "when the URL is http" do
      before do
        opts[:url] = "http://example.com"
      end

      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL is https" do
      before do
        opts[:url] = "https://example.com"
      end

      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL isn't an allowed scheme" do
      before do
        opts[:url] = "gopher://example.com"
      end

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
      before do
        opts[:url] = "This isn't a URI"
      end

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
      before do
        opts[:url] = nil
      end

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["can't be blank"]
      end
    end
  end

  describe "#preview?" do
    context "when preview is '1'" do
      before do
        opts[:preview] = "1"
      end

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
