require 'rails_helper'

RSpec.describe ImportForm do
  let(:url) { "http://example.com" }
  let(:preview) { "0" }
  let(:form) { ImportForm.new(:url => url, :preview => preview) }
  let(:rdf_importer) { instance_double("RdfImporter") }
  let(:term_list) { instance_double("ImportableTermList") }

  before do
    allow(RdfImporter).to receive(:new).with(form.errors, url).and_return(rdf_importer)
    allow(rdf_importer).to receive(:run).and_return(term_list)
  end

  describe "#valid?" do
    it "should return the state of errors.empty?" do
      expect(form.errors).to receive(:empty?).and_return(:state)
      expect(form.valid?).to eq(:state)
    end

    it "should call the rdf importer" do
      expect(rdf_importer).to receive(:run)
      form.valid?
    end

    context "when the rdf importer has already been run" do
      it "should not call the rdf importer a second time" do
        expect(RdfImporter).to receive(:new).with(form.errors, url).and_return(rdf_importer).once
        form.valid?
        form.valid?
      end
    end
  end

  describe "#save" do
    context "when the form isn't valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "should return false" do
        expect(form.save).to eq(false)
      end

      it "shouldn't save the term list" do
        expect(term_list).not_to receive(:save)
        form.save
      end
    end

    context "when the form is a preview" do
      let(:preview) { "1" }

      it "should return true" do
        expect(form.save).to eq(true)
      end

      it "shouldn't save the term list" do
        expect(term_list).not_to receive(:save)
        form.save
      end
    end

    context "when the form is valid and not a preview" do
      it "should save the term list" do
        expect(term_list).to receive(:save)
        form.save
      end
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
        expect(form.term_list).to eq(term_list)
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
