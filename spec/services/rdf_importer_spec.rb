require 'rails_helper'

RSpec.describe RdfImporter do
  let(:url) { "http://example.com" }
  let(:errors) { ActiveModel::Errors.new(ImportForm.new) }
  let(:importer) { RdfImporter.new(errors) }
  let(:url_to_graph) { double("url_to_graph") }
  let(:graph) { instance_double("RDF::Graph") }
  let(:graph_to_termlist) { double("graph_to_termlist") }
  let(:termlist) { instance_double("ImportableTermList") }
  let(:validator_class) { IsValidRdfImportUrl }
  let(:validator) { instance_double("IsValidRdfImportUrl") }

  before do
    allow(importer).to receive(:url_to_graph).and_return(url_to_graph)
    allow(url_to_graph).to receive(:call).with(url).and_return(graph)
    allow(graph).to receive(:empty?).and_return(false)

    allow(importer).to receive(:graph_to_termlist).and_return(graph_to_termlist)
    allow(graph_to_termlist).to receive(:call).with(graph).and_return(termlist)
    allow(termlist).to receive(:valid?).and_return(true)

    allow(importer).to receive(:validators).and_return([validator_class])
    allow(validator_class).to receive(:new).and_return(validator)
    allow(validator).to receive(:validate).with(importer)

    expect(importer).not_to receive(:injector)
  end

  describe "#call" do
    context "when there are no errors" do
      it "should set the term_list" do
        importer.call(url)
        expect(importer.term_list).to eq(termlist)
      end
    end

    context "when there's an error in the validator" do
      before do
        expect(validator).to receive(:validate).with(importer) { errors.add(:base, "validator error") }
      end

      it "shouldn't call url_to_graph" do
        expect(url_to_graph).not_to receive(:call)
        importer.call(url)
      end

      it "shouldn't call graph_to_termlist" do
        expect(graph_to_termlist).not_to receive(:call)
        importer.call(url)
      end
    end

    context "when an empty graph is returned" do
      before do
        expect(url_to_graph).to receive(:call).with(url).and_return(graph)
        expect(graph).to receive(:empty?).and_return(true)
      end

      it "should add an error" do
        importer.call(url)
        expect(importer.errors.count).to eq(1)
        expect(importer.errors[:url]).to eq(["must resolve to valid RDF"])
      end

      it "shouldn't call graph_to_termlist" do
        expect(graph_to_termlist).not_to receive(:call)
        importer.call(url)
      end
    end

    context "when the term list is invalid" do
      let(:termlist_errors) { double("errors") }
      let(:full_messages) { (1..12).to_a }
      before do
        expect(termlist).to receive(:valid?).and_return(false)
        expect(termlist).to receive(:errors).and_return(termlist_errors)
        expect(termlist_errors).to receive(:full_messages).and_return(full_messages)
      end

      it "should propagate up to ten errors from the termlist" do
        importer.call(url)
        expect(importer.errors.count).to eq(11)
        0.upto(9) {|i| expect(importer.errors[:base][i]).to eq(i+1)}
        expect(importer.errors[:base][10]).to eq("Further errors exist but were suppressed")
      end
    end
  end
end
