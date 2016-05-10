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
        expect(RdfLoader.load_url(url)).to eq(graph)
      end
    end

    context "when loading raises an error" do
      let(:new_graph) { instance_double("RDF::Graph") }
      before do
        expect(RDF::Graph).to receive(:load).with(url) { raise StandardError.new }
        expect(RDF::Graph).to receive(:new).and_return(new_graph)
      end

      it "returns a blank graph on exceptions" do
        expect(RdfLoader.load_url(url)).to eq(new_graph)
      end
    end
  end
  describe ".call" do
    let(:jsonld) { '{
    "@context": {
      "dc": "http://purl.org/dc/terms/",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
              "skos": "http://www.w3.org/2004/02/skos/core#",
                  "xsd": "http://www.w3.org/2001/XMLSchema#"
                    },
                      "@id": "http://opaquenamespace.org/ns/workType/aibanprints",
    "@type": "skos:Concept",
    "dc:issued": {
        "@value": "2015-07-16",
        "@type": "xsd:date"
      },
    "dc:modified": {
          "@value": "2015-07-16",
          "@type": "xsd:date"
        },
    "rdfs:comment": {
            "@value": "Yamane, Y?z?; F?zokuga to Ukiyoe shi (Genshoku Nihon no Bijutsu, v.24), 1971. Japanese prints aproximately 34.5 x 22.5 cm or (9 x 13 in). ",
                "@language": "en"
          },
    "rdfs:isDefinedBy": {
              "@id": "http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"
            },
    "rdfs:label": {
                "@value": "aiban (prints)",
                    "@language": "en"
              }
  }'}
    let(:graph) { instance_double("RDF::Graph") }

    context "when loading raises an error" do
      let(:new_graph) { RDF::Graph.new }
      before do
        expect(JSON).to receive(:parse).with(jsonld)
      end

      it "returns a blank graph on exceptions" do
        expect(RdfLoader.load_string(jsonld)).to eq(new_graph)
      end
    end
  end
end
