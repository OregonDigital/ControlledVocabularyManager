require 'rails_helper'

RSpec.describe ImportForm do
  let(:url) { "http://example.com" }
  let(:preview) { "0" }
  let(:form) { ImportForm.new(:url => url, :preview => preview) }
  let(:rdf_importer) { instance_double("RdfImporter") }
  let(:term_list) { instance_double("ImportableTermList") }

  before do
    allow(RdfImporter).to receive(:new).and_return(rdf_importer)
    allow(rdf_importer).to receive(:term_list).and_return(term_list)
  end

  describe ".new" do
    it "should create an RdfImporter" do
      expect(RdfImporter).to receive(:new).and_return(rdf_importer)
      form
    end
  end

  describe "#valid?" do
    it "should return the state of errors.empty?" do
      expect(form.errors).to receive(:empty?).and_return(:state)
      expect(form.valid?).to eq(:state)
    end

    context "when the rdf importer hasn't produced a term list" do
      before do
        expect(rdf_importer).to receive(:term_list).and_return(nil)
      end

      it "should call the rdf importer" do
        expect(rdf_importer).to receive(:call).with(form.url)
        form.valid?
      end
    end

    context "when the rdf importer has already produced a term list" do
      it "should not call the rdf importer" do
        expect(rdf_importer).not_to receive(:call)
        form.valid?
      end
    end
  end

  describe "#save" do
    let(:valid) { true }
    let(:preview) { false }

    before do
      allow(form).to receive(:valid?).and_return(valid)
      allow(form).to receive(:preview?).and_return(preview)
      allow(term_list).to receive(:save)
    end

    context "when the form isn't valid" do
      let(:valid) { false }

      it "should return false" do
        expect(form.save).to eq(false)
      end

      it "shouldn't save the term list" do
        expect(term_list).not_to receive(:save)
        form.save
      end
    end

    context "when the form is a preview" do
      let(:preview) { true }

      it "should return true" do
        expect(form.save).to eq(true)
      end

      it "shouldn't save the term list" do
        expect(term_list).not_to receive(:save)
        form.save
      end
    end

    it "should save the term list" do
      expect(term_list).to receive(:save)
      form.save
    end
  end

  describe "#term_list" do
    before do
      allow(rdf_importer).to receive(:term_list).and_return(term_list)
    end

    it "should return rdf_importer's term list" do
      expect(form.term_list).to eq(rdf_importer.term_list)
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
