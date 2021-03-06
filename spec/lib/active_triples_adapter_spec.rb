# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveTriplesAdapter do
  before do
    # Example Resource
    example_resource = Class.new(ActiveTriples::Resource) do
      include ActiveTriplesAdapter
      configure repository: :default
      configure type: RDF::URI('http://purl.org/dc/dcam/VocabularyEncodingScheme')
      configure base_uri: 'http://opaquenamespace.org/ns/'
    end
    stub_const('ExampleResource', example_resource)
  end

  let(:resource) { ExampleResource.new(uri) }
  let(:uri) { 'http://opaquenamespace.org/ns/bla' }
  let(:id) { 'bla' }
  let(:repository) { ActiveTriples::Repositories.repositories[:default] }

  before do
    stub_repository
  end

  describe '#new' do
    context "when there's nothing in the repository" do
      it 'is not persisted' do
        expect(resource).not_to be_persisted
      end
    end

    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, 'bla')
      end

      it 'is not persisted' do
        expect(resource).not_to be_persisted
      end

      it 'has no triples' do
        expect(resource.statements.to_a.length).to eq 1
      end
    end

    context 'and then triples are persisted' do
      before do
        resource << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, 'bla')
        resource.persist!
      end

      it 'is persisted' do
        expect(resource).to be_persisted
      end
    end
  end

  describe '#find' do
    let(:resource) { ExampleResource.find(id) }

    context "when there's nothing in the repository" do
      it 'raises an exception' do
        expect { resource }.to raise_error(ActiveTriples::NotFound)
      end
    end

    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, 'bla')
      end

      it 'is persisted' do
        expect(resource).to be_persisted
      end

      it 'has statements' do
        expect(resource.statements.to_a.length).not_to eq 0
      end
    end
  end

  describe '#exists?' do
    let(:result) { ExampleResource.exists?(id) }

    context "when there's nothing in the repository" do
      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'when asking for a blank string' do
      let(:id) { '' }

      it 'is false' do
        expect(result).to eq false
      end
    end

    context 'when asking for a blank node' do
      let(:id) { RDF::Node.new.to_s }

      it 'is false' do
        expect(result).to eq false
      end
    end

    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, 'bla')
      end

      it 'is true' do
        expect(result).to eq true
      end
    end
  end
end
