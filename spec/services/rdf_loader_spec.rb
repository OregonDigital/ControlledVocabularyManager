# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RdfLoader do
  describe '.call' do
    let(:empty_graph) { RDF::Graph.new }

    describe 'when loading a url' do
      let(:url) { 'http://opaquenamespace.org/ns/workType/aibanprints.jsonld' }

      before do
        WebMock.allow_net_connect!
      end

      context 'when the graph loads' do
        let(:graph) { described_class.load_url(url) }

        it 'returns a graph' do
          expect(graph).to be_an_instance_of(RDF::Graph)
          expect(graph.each_statement.to_a.length).to be > 0
        end
      end

      context 'when loading raises a standard error' do
        before do
          allow(RestClient).to receive(:get) { raise StandardError }
        end

        it 'returns a blank graph on exceptions' do
          expect(described_class.load_url(url)).to eq empty_graph
        end
      end
    end

    describe 'when loading a file' do
      before(:all) do
        File.open('/tmp/test.nt', 'w') do |file|
          file.write('<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/issued> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/modified> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/publisher> "asfsdafdsf"@cr .
        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/title> "asdfsdfsadf"@fo .
        <http://opaquenamespace.org/ns/TESTTEST> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/dc/dcam/VocabularyEncodingScheme> .')
        end
      end

      let(:ntriples) do
        '<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/issued> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
      <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/modified> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
      <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/publisher> "asfsdafdsf"@cr .
      <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/title> "asdfsdfsadf"@fo .
      <http://opaquenamespace.org/ns/TESTTEST> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/dc/dcam/VocabularyEncodingScheme> .'
      end
      let(:filename) { '/tmp/test.nt' }
      let(:expected_graph) do
        graph = RDF::Graph.new
        RDF::Reader.for(:ntriples).new(ntriples) do |reader|
          reader.each_statement do |statement|
            graph << statement
          end
        end
        graph
      end
      let(:graph) { described_class.load_file(filename) }

      it 'reads the file' do
        expect(graph.each_statement.to_a.length).to be > 0
        expect(graph).to eq expected_graph
      end

      context 'with an invalid filename' do
        let(:filename) { "/tmp/bogus-filename-#{DateTime.now}" }

        it 'returns an empty graph for an invalid file' do
          expect(graph.each_statement.to_a.length).to eq 0
          expect(graph).not_to eq expected_graph
        end
      end

      context 'with a locked file' do
        before do
          File.chmod(0o222, filename)
        end

        after do
          File.chmod(0o666, filename)
        end

        it 'returns an empty graph' do
          expect(graph.each_statement.to_a.length).to eq 0
          expect(graph).not_to eq expected_graph
        end
      end
    end

    describe 'when loading a string' do
      let(:jsonld) do
        '{
        "@context": {
          "dc": "http://purl.org/dc/terms/",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
          "skos": "http://www.w3.org/2004/02/skos/core#",
          "xsd": "http://www.w3.org/2001/XMLSchema#"
        },
        "@id": "http://opaquenamespace.org/ns/workType/aibanprints",
        "@type": [
          "skos:Concept",
          "rdfs:Resource"
        ],
        "dc:issued": {
          "@value": "2015-07-16",
          "@type": "xsd:date"
        },
        "dc:modified": {
          "@value": "2015-07-16",
          "@type": "xsd:date"
        },
        "rdfs:comment": {
          "@value": "Yamane, Y?z?; F?zokuga to Ukiyoe shi (Genshoku Nihon no Bijutsu, v.24), 1971. Japanese prints aproximately 34.5 x 22.5 cm or (9 x 13 in).",
          "@language": "en"
        },
        "rdfs:isDefinedBy": {
          "@id": "http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"
        },
        "rdfs:label": {
          "@value": "aiban (prints)",
          "@language": "en"
        },
        "rdfs:seeAlso": {
          "@id": "http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"
        }
      }'
      end

      let(:graph) { described_class.load_string(jsonld) }

      context 'when the graph loads' do
        it 'returns the graph' do
          expect(graph).to be_an_instance_of(RDF::Graph)
          expect(graph.each_statement.to_a.length).to be > 0
        end
      end

      context 'when loading raises a standard error' do
        before do
          allow_any_instance_of(RDF::Graph).to receive(:<<) { raise StandardError }
        end

        it 'returns a blank graph on exceptions' do
          expect(described_class.load_string(jsonld).each_statement.to_a.length).to eq 0
        end
      end
    end
  end
end
