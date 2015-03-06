require 'rails_helper'

RSpec.describe RdfFetcher do
  describe ".call" do
    let(:url) { "http://example.com" }
    let(:graph) { instance_double("RDF::Graph") }
    let(:result) { RdfFetcher.call(url) }

    before do
      allow(RDF::Graph).to receive(:load).with(url).and_return(graph)
    end

    context "when the URL's scheme is http" do
      let(:url) { "http://example.com" }
      it "should return the graph" do
        expect(result).to eq(graph)
      end
    end

    context "when the URL's scheme is https" do
      let(:url) { "https://example.com" }
      it "should return the graph" do
        expect(result).to eq(graph)
      end
    end

    context "when the URL's scheme is invalid" do
      let(:url) { "gopher://example.com" }
      it "should raise InvalidURI" do
        expect{result}.to raise_error(RdfFetcher::InvalidURI)
      end
    end
  end
end
