# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermWithChildren do
  subject { described_class.new(vocabulary, injector.child_node_finder) }

  let(:vocabulary) { Vocabulary.new(uri) }
  let(:uri) { 'http://opaquenamespace.org/ns/bla' }
  let(:injector) { TermInjector.new }
  let(:term_repository) { injector.term_form_repository }

  describe '#children' do
    let(:result) { subject.children }

    context 'with no children exist' do
      it 'returns nothing' do
        expect(subject.children).to eq []
      end
    end

    context 'with children' do
      let(:child) { term_repository.new(uri + '/1') }
      let(:child_2) { term_repository.new(uri + 'q/2') }

      before do
        child.persist!
        child_2.persist!
      end

      it 'returns children' do
        expect(subject.children.map(&:rdf_subject)).to eq [child.rdf_subject]
      end
    end
  end

  describe '#full_graph' do
    context 'with no children' do
      it 'is the resource' do
        expect(subject.full_graph.statements.to_a).to eq subject.statements.to_a
      end
    end

    context 'with children' do
      let(:child) { term_repository.new(uri + '/1') }
      let(:unrelated_term) { term_repository.new(uri + 'q/2') }

      before do
        child.persist!
        unrelated_term.persist!
      end

      it 'has terms of itself and its children' do
        expect(subject.full_graph.count).to eq child.count + subject.count
      end
    end
  end

  describe '#sort_stringify' do
    before do
      vocabulary << RDF::Statement.new(RDF::URI('http://opaquenamespace.org/ns/bla'), RDF::URI('http://schema.org/alternateName'), RDF::Literal('blah'))
    end

    it 'returns a sorted stringified graph' do
      expect(subject.sort_stringify(subject.full_graph)).to be_a String
    end
  end
end
