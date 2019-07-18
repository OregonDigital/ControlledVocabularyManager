# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadForm do
  let(:jsonld) do
    '{
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
  }'
  end
  let(:term_list) { instance_double('ImportableTermList') }
  let(:validators) { instance_double('IsValidRdfString') }
  let(:form) { described_class.new(jsonld, RdfImporter) }

  describe '#valid?' do
    it 'returns the state of errors.empty?' do
      expect(form.errors).to receive(:empty?).and_return(:state)
      expect(form.valid?).to eq(:state)
    end

    it 'calls the rdf importer' do
      expect(form).to receive(:run)
      form.valid?
    end
  end

  describe '#term_list' do
    context "when the importer hasn't been run" do
      it 'is nil' do
        expect(form.term_list).to eq(nil)
      end
    end

    context 'when the importer has been run' do
      it "is the importer's `run` result" do
        form.valid?
        expect(form.term_list.size).to be > 0
      end
    end
  end
end
