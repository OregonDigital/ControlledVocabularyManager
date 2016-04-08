require 'rails_helper'

RSpec.describe ChildNodeFinder do
  describe "#find_children" do
    subject { ChildNodeFinder.new(repository, sparql_client) }
    let(:vocabulary) { Vocabulary.new("bla") }
    let(:repository) { TermInjector.new.term_form_repository }
    let(:sparql_client) { VocabularyInjector.new.sparql_client.select.graph("#{Settings.marmotta.url}/context/test")}
    let(:term) { repository.new("bla/1") }
    let(:unrelated_term) { repository.new("bla2/1") }
    let(:result) { subject.find_children(vocabulary) }
    before do
      vocabulary.persist!
      term.persist!
      unrelated_term.persist!
    end
    def statements_hash(graph)
      graph.statements.to_a.map{|x| x.to_hash}.sort_by{|x| x[:predicate]}
    end
    it "should return all children" do
      expect(result.length).to eq 1
      expect(statements_hash(result.first)).to eq statements_hash(term)
    end
    context "when there are four children" do
      let(:unrelated_term) { repository.new("bla/2") }
      let(:another_term) { repository.new("bla/Foo") }
      let(:another_term2){ repository.new("bla/blue") }
      let(:sorted_result) { result.sort_by{|i| i.rdf_subject.to_s.downcase} }
      before do
        unrelated_term.persist!
        another_term.persist!
        another_term2.persist!
      end
      it "should be able to return them" do
        expect(result.length).to eq 4
        expect(statements_hash(sorted_result.first)).to eq statements_hash(term)
        expect(statements_hash(sorted_result.last)).to eq statements_hash(another_term)
      end
    end
  end
end
