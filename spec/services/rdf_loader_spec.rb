require 'rails_helper'

RSpec.describe RdfLoader do
  describe ".call" do
    let(:url) { "http://example.com" }
    let(:graph) { instance_double("RDF::Graph") }

    context "when the graph loads" do
      before do
        expect(RDF::Graph).to receive(:load).with(url).and_return(graph)
      end

      it "returns the result of RDF::Graph.load" do
        expect(RdfLoader.call(url)).to eq(graph)
      end
    end

    context "when loading raises an error" do
      let(:new_graph) { instance_double("RDF::Graph") }
      before do
        expect(RDF::Graph).to receive(:load).with(url) { raise StandardError.new }
        expect(RDF::Graph).to receive(:new).and_return(new_graph)
      end

      it "returns a blank graph on exceptions" do
        expect(RdfLoader.call(url)).to eq(new_graph)
      end
    end
  end
end
