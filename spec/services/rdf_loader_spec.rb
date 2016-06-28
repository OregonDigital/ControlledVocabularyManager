require 'rails_helper'

RSpec.describe RdfLoader do
  describe ".call" do
    let(:url) { "http://opaquenamespace.org/ns/workType/aibanprints" }
    before do
      WebMock.allow_net_connect!
      RdfLoader.load_url(url)
    end
    context "when the graph loads" do
      let(:graph) { RdfLoader.load_url(url) }
      it "returns the result of RDF::Graph.load" do
        expect(graph).to be_an_instance_of(RDF::Graph)
      end
    end

    context "when loading raises an error" do
      let(:new_graph) { instance_double("RDF::Graph") }
      before do
        allow_any_instance_of(TriplestoreAdapter::Triplestore).to receive(:fetch) { raise TriplestoreAdapter::TriplestoreException }
        expect(RDF::Graph).to receive(:new).and_return(new_graph)
      end

      it "returns a blank graph on exceptions" do
        expect(RdfLoader.load_url(url)).to eq(new_graph)
      end
    end
  end
end
