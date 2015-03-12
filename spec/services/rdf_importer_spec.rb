require 'rails_helper'

RSpec.describe RdfImporter do
  let(:url) { "http://example.com" }
  let(:errors) { instance_double("ActiveModel::Errors") }
  let(:importer) { RdfImporter.new(errors, url) }
  let(:url_to_graph) { class_double("RdfLoader") }
  let(:graph) { instance_double("RDF::Graph") }
  let(:graph_to_termlist) { instance_double("GraphToImportableTermList") }
  let(:termlist) { instance_double("ImportableTermList") }
  let(:validator_class) { IsValidRdfImportUrl }
  let(:validator) { instance_double("IsValidRdfImportUrl") }

  before do
    allow(importer).to receive(:url_to_graph).and_return(url_to_graph)
    allow(url_to_graph).to receive(:call).with(url).and_return(graph)
    allow(graph).to receive(:empty?).and_return(false)

    allow(GraphToImportableTermList).to receive(:new).with(graph).and_return(graph_to_termlist)
    allow(graph_to_termlist).to receive(:run).with(no_args).and_return(termlist)
    allow(termlist).to receive(:valid?).and_return(true)

    allow(importer).to receive(:validators).and_return([validator_class])
    allow(validator_class).to receive(:new).and_return(validator)
    allow(validator).to receive(:validate).with(importer)
  end

  describe "#run" do
    context "when there are no errors" do
      let(:error_propagator) { instance_double("ErrorPropagator") }

      before do
        allow(errors).to receive(:any?).and_return(false)
      end

      it "should return the term_list" do
        expect(importer.run).to eq(termlist)
      end

      it "should call the error propagator on the termlist" do
        expect(ErrorPropagator).to receive(:new).with(termlist, errors, 10).and_return(error_propagator)
        expect(error_propagator).to receive(:run)
        importer.run
      end
    end

    context "Presence of errors preventing code execution" do
      context "When there are errors in all cases" do
        before do
          expect(errors).to receive(:any?).and_return(true, true)
        end

        it "shouldn't call url_to_graph" do
          expect(url_to_graph).not_to receive(:call)
          importer.run
        end

        it "shouldn't call graph_to_termlist" do
          expect(graph_to_termlist).not_to receive(:run)
          importer.run
        end
      end

      context "when there is no error on the first call" do
        before do
          expect(errors).to receive(:any?).and_return(false, true)
        end

        it "should call url_to_graph" do
          expect(url_to_graph).to receive(:call)
          importer.run
        end

        it "shouldn't call graph_to_termlist" do
          expect(graph_to_termlist).not_to receive(:run)
          importer.run
        end
      end
    end

    context "when an empty graph is returned" do
      before do
        expect(url_to_graph).to receive(:call).with(url).and_return(graph)
        expect(graph).to receive(:empty?).and_return(true)
        allow(errors).to receive(:add)
        allow(errors).to receive(:any?).and_return(false, false)
      end

      it "should add an error" do
        expect(errors).to receive(:add).with(:url, "must resolve to valid RDF")
        importer.run
      end
    end
  end
end
