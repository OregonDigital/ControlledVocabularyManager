require 'rails_helper'

RSpec.describe RdfImporter do
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
  let(:url) { "http://opaquenamespace.org/ns/workType/aibanprints" }
  let(:errors) { instance_double("ActiveModel::Errors") }
  let(:importer) { RdfImporter.new(errors, url: url, validators: [validator]) }
  let(:rdf_loader) { RdfLoader }
  let(:graph_to_termlist) { instance_double("GraphToImportableTermList") }
  let(:termlist) { ImportableTermList.new }
  let(:validator_class) { IsValidRdfImportUrl }
  let(:validator) { instance_double("IsValidRdfImportUrl") }

  describe "#run for RDF URL" do
    before do
      WebMock.allow_net_connect!

      RdfLoader.load_url(url)
      allow(graph_to_termlist).to receive(:run).with(no_args).and_return(termlist)
      allow(termlist).to receive(:valid?).and_return(true)
      allow(importer).to receive(:validators).and_return([validator_class])
      allow(validator_class).to receive(:new).and_return(validator)
      allow(validator).to receive(:validate).with(importer)
    end

    context "when there are no errors" do
      before do
        allow(errors).to receive(:any?).and_return(false)
      end

      it "should return the term_list" do
        importer.run
        expect(importer.term_list.terms.size).to be > 0
      end
    end

    context "Presence of errors preventing code execution" do
      context "When there are errors in all cases" do
        before do
          expect(errors).to receive(:any?).and_return(true)
        end

        it "shouldn't call rdf_loader" do
          expect(rdf_loader).not_to receive(:load_url)
          importer.run
        end

        it "shouldn't call graph_to_termlist" do
          expect(importer).not_to receive(:build_term_list)
          importer.run
        end
      end

      context "when there is no error on the first call" do
        before do
          stub_request(:get, url).to_return(:status => 200, :body => jsonld, :headers => {})
          expect(errors).to receive(:any?).and_return(false, true)
        end

        it "shouldn't return build_term_list" do
          expect(importer).to receive(:build_graph)
          expect(importer).not_to receive(:build_term_list)
          importer.run
        end
      end
    end

    context "when an empty graph is returned" do
      before do
        stub_request(:get, url).to_return(:status => 200, :body => jsonld, :headers => {})
        allow(errors).to receive(:any?).and_return(false, true)
        allow(rdf_loader).to receive(:load_url).and_return(RDF::Graph.new)
      end

      it "should add an error" do
        expect(errors).to receive(:add).with(:url, "must resolve to valid RDF")
        expect(errors).to receive(:add).with(:base, "URL is not valid.")
        importer.run
      end
    end
  end
  describe "#run for RDF String" do
    let(:validator) { instance_double("IsValidRdfString") }
    let(:importer) { RdfImporter.new(errors, rdf_string: jsonld, validators: [validator]) }

    before do
      WebMock.allow_net_connect!

      allow(graph_to_termlist).to receive(:run).with(no_args).and_return(termlist)
      allow(termlist).to receive(:valid?).and_return(true)
      allow(importer).to receive(:validators).and_return([validator_class])
      allow(validator_class).to receive(:new).and_return(validator)
      allow(validator).to receive(:validate).with(importer)
    end

    context "when there are no errors" do
      before do
        allow(errors).to receive(:any?).and_return(false)
      end

      it "should return the term_list" do
        importer.run
        expect(importer.term_list.terms.size).to be > 0
      end
    end

    context "Presence of errors preventing code execution" do
      context "When there are errors in all cases" do
        before do
          expect(errors).to receive(:any?).and_return(true)
        end

        it "shouldn't call rdf_loader" do
          expect(rdf_loader).not_to receive(:load_string)
          importer.run
        end

        it "shouldn't call graph_to_termlist" do
          expect(importer).not_to receive(:build_term_list)
          importer.run
        end
      end

      context "when there is no error on the first call" do
        before do
          expect(errors).to receive(:any?).and_return(false, true)
        end

        it "shouldn't return build_term_list" do
          expect(importer).to receive(:build_graph)
          expect(importer).not_to receive(:build_term_list)
          importer.run
        end
      end
    end

    context "when an empty graph is returned" do
      let(:jsonld) { "not-blank-not-valid" }
      before do
        allow(errors).to receive(:any?).and_return(false, true)
      end

      it "should add an error" do
        expect(errors).to receive(:add).with(:rdf_string, "invalid RDF")
        expect(errors).to receive(:add).with(:base, "Text contains invalid RDF.")
        importer.run
      end
    end
  end
end
