# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphToTerms do
  subject { described_class.new(repository, graph) }

  let(:klass) { Vocabulary }
  let(:predicate) { RDF::URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') }
  let(:rdf_statement) { RDF::Statement.new(nil, predicate, klass.type) }
  let(:graph) { instance_double('RDF::Graph') }
  let(:repository) { instance_double('StandardRepository') }
  let(:triples) { [rdf_statement] }

  describe '#type_of_graph' do
    context 'each type of terms' do
      [Vocabulary, Predicate, Term, CorporateName, Geographic, LocalCollection, PersonalName, Title, Topic].each do |x|
        let(:klass) { x }
        it "#{x} should return the proper class" do
          subject.type_of_graph(triples)
          expect(subject.klass).to eq(klass)
        end
      end
    end
  end
end
