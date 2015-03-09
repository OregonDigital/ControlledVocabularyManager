require 'rails_helper'

RSpec.describe RdfFetcher do
  describe ".call" do
    let(:url) { "http://example.com" }
    let(:graph) { instance_double("RDF::Graph") }

    it "calls RDF::Graph.load" do
      expect(RDF::Graph).to receive(:load).with(url).and_return(graph)
      RdfFetcher.call(url)
    end
  end
end
