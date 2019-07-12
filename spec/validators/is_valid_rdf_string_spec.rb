# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IsValidRdfString do
  describe '#validate' do
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
    let(:record) { double('record') }
    let(:errors) { double('errors') }
    let(:validate) { described_class.new.validate(record) }

    before do
      allow(record).to receive(:errors).and_return(errors)
      allow(record).to receive(:rdf_string).and_return(jsonld)
    end

    context 'when the string is valid' do
      it 'does not add errors' do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context 'when the string is missing' do
      let(:jsonld) { nil }

      it 'adds an error' do
        expect(errors).to receive(:add).with(:rdf_string, "can't be blank")
        expect(errors).to receive(:add).with(:base, 'RDF text cannot be blank.')
        validate
      end
    end
  end
end
