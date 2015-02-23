require 'rails_helper'

RSpec.describe ChildNodeFinder do
  describe ".find_children" do
    let(:result) { described_class.find_children(vocabulary) }
    let(:vocabulary) { Vocabulary.new("bla") }
    let(:term) { Term.new("bla/1") }
    let(:unrelated_term) { Term.new("bla2/1") }
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
    context "when there are two children" do
      let(:unrelated_term) { Term.new("bla/2") }
      it "should be able to return them" do
        expect(result.length).to eq 2
        expect(statements_hash(result.first)).to eq statements_hash(term)
        expect(statements_hash(result.last)).to eq statements_hash(unrelated_term)
      end
    end
  end
end
