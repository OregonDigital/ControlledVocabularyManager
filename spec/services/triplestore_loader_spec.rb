# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TriplestoreLoader do
  let(:loader) do
    TriplestoreLoader.new({ type: Settings.triplestore_adapter.type,
                            url: Settings.triplestore_adapter.url,
                            write_report: true,
                            update_triplestore: true,
                            write_update_file: true,
                            output_dir: '/tmp'
                          })
  end
  before(:all) do
    WebMock.allow_net_connect!

    File.open('/tmp/test.nt', 'w') do |file|
      file.write('<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/issued> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/modified> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/publisher> "asfsdafdsf"@cr .
<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/title> "asdfsdfsadf"@fo .
<http://opaquenamespace.org/ns/TESTTEST> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/dc/dcam/VocabularyEncodingScheme> .')
    end
    File.open('/tmp/test2.nt', 'w') do |file|
      file.write('<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/issued> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/title> "asdfsdfsadf"@fo .
<http://opaquenamespace.org/ns/TESTTEST> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/dc/dcam/VocabularyEncodingScheme> .')
    end
  end

  it "should initialize a triplestore" do
    expect(loader.triplestore).to be_a TriplestoreAdapter::Triplestore
  end

  it "should return no errors" do
    errors = loader.process('/tmp/test.nt')
    expect(errors).to be_a_kind_of Hash
    expect(errors.values.length).to eq 0
  end


  it "should return errors" do
    allow(loader).to receive(:fetch_graph).and_return(nil)
    errors = loader.process('/tmp/test.nt')
    expect(errors).to be_a_kind_of Hash
    expect(errors.key?('http://opaquenamespace.org/ns/TESTTEST')).to be_truthy
    expect(errors.values.length).to eq 1
  end

  it "should raise StandardError errors sometimes" do
    allow(loader.triplestore).to receive(:fetch).and_raise(StandardError)
    errors = loader.process('/tmp/test.nt')
    expect(errors.values.length).to eq 1
  end

  it "should raise TriplestoreAdapter::TriplestoreException errors sometimes" do
    allow(loader.triplestore).to receive(:fetch).and_raise(TriplestoreAdapter::TriplestoreException)
    errors = loader.process('/tmp/test.nt')
    expect(errors.values.length).to eq 1
  end

  it "should raise StandardError when finding mismatching statements sometimes" do
    allow(loader).to receive(:fetch_graph).and_return([])
    errors = loader.process('/tmp/test.nt')
    expect(errors.values.length).to eq 1
  end

  context "when writing an output file" do
     let(:loader) do
      TriplestoreLoader.new({ type: Settings.triplestore_adapter.type,
                              url: Settings.triplestore_adapter.url,
                              write_report: false,
                              update_triplestore: true,
                              write_update_file: true,
                              output_dir: '/tmp'
                            })
     end
    before do
      loader.process('/tmp/test.nt')
    end

    it "should write an updated file with statements found in the triplestore" do
      errors = loader.process('/tmp/test2.nt')
      expect(errors.values.length).to eq 0
    end
  end
  context "when a triplestore has more statements than the file" do
    let(:loader) do
      TriplestoreLoader.new({ type: Settings.triplestore_adapter.type,
                              url: Settings.triplestore_adapter.url,
                              write_report: false,
                              update_triplestore: true,
                              write_update_file: false,
                              output_dir: '/tmp'
                            })
    end

    before do
      loader.process('/tmp/test.nt')
    end

    it "should detect the triplestore having more statements" do
      errors = loader.process('/tmp/test2.nt')
      mismatches = loader.mismatches
      expect(errors.values.length).to eq 0
      expect(mismatches.key?('http://opaquenamespace.org/ns/TESTTEST')).to be_truthy

      predicates_not_in_file = mismatches['http://opaquenamespace.org/ns/TESTTEST'][:not_in_file].map { |s| s.predicate }
      expect(predicates_not_in_file).to include RDF::DC::modified
      expect(predicates_not_in_file).to include RDF::DC::publisher
      expect(mismatches['http://opaquenamespace.org/ns/TESTTEST'][:not_in_triplestore].length).to eq 0
    end
  end

  context "when a file has more statements than the triplestore" do
    let(:loader) do
      TriplestoreLoader.new({ type: Settings.triplestore_adapter.type,
                              url: Settings.triplestore_adapter.url,
                              write_report: false,
                              update_triplestore: true,
                              write_update_file: false,
                              output_dir: '/tmp'
                            })
    end

    before do
      loader.process('/tmp/test2.nt')
    end

    it "should detect the file having more statements" do
      errors = loader.process('/tmp/test.nt')
      mismatches = loader.mismatches
      expect(errors.values.length).to eq 0
      expect(mismatches.key?('http://opaquenamespace.org/ns/TESTTEST')).to be_truthy

      predicates_not_in_triplestore = mismatches['http://opaquenamespace.org/ns/TESTTEST'][:not_in_triplestore].map { |s| s.predicate }
      expect(predicates_not_in_triplestore).to include RDF::DC::modified
      expect(predicates_not_in_triplestore).to include RDF::DC::publisher
      # not_in_file can sometimes include an RDF statement that ActiveTriples assigns to Vocabs and Predicates (which aren't stripped by Term.rb term type decorator)
      # such as rdfs resource
      expect(mismatches['http://opaquenamespace.org/ns/TESTTEST'][:not_in_file].length).to eq 1
    end
  end
end
