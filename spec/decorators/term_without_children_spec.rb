# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermWithoutChildren do
  describe 'sort_stringify' do
    let(:term) { term_mock }
    let(:injector) { VocabularyInjector.new }
    let(:twc) { described_class.new(term) }
    let(:graph) { RDF::Graph.new }
    let(:subj) { RDF::URI.new('http://opaquenamespace.org/ns/blip') }
    let(:pred1) { RDF::URI.new('http://purl.org/dc/terms/date') }
    let(:pred2) { RDF::URI.new('http://www.w3.org/2000/01/rdf-schema#label') }

    before do
      graph << RDF::Statement.new(subj, pred2, 'blippity')
      graph << RDF::Statement.new(subj, pred1, '2016-05-04')
    end

    it 'sorts the triples' do
      result = twc.sort_stringify(graph)
      parts = result.split(' . ')
      expect(parts.first).to include('date')
    end
  end
end
