require 'rails_helper'

RSpec.describe TermSearch do
  subject { TermSearch.new(sparql_client) }
  let(:sparql_client) { Term.new.repository.query_client }

  describe "#search" do

    def build_relevant_term(factory, id, query)
      t = factory.new(id)
      t.label = "afadf#{query}afadf"
      t.persist!
      t
    end
    let(:query) { "banana" }
    let(:results) { subject.search(query) }
    context "when there are no results" do
      it "should return a blank array" do
        expect(results).to eq []
      end
    end
    context "when there are results" do
      let(:term) do
        build_relevant_term(Term, "vocab/id", query)
      end
      before do
        term
      end
      it "should return it" do
        expect(results).to eq [term]
      end
      context "with terms and vocabularies" do
        before do
          build_relevant_term(Vocabulary, "id", query)
          build_relevant_term(Term, "id/term", query)
        end
        it "should return terms and vocabularies" do
          expect(results.map(&:class)).to eq [Term, Vocabulary, Term]
        end
      end
      context "which are vocabularies" do
        let(:term) do
          build_relevant_term(Vocabulary, "vocab", query)
        end
        it "should return a vocabulary" do
          expect(results).to eq [term]
          expect(results.first).to be_instance_of Vocabulary
        end
      end
    end
  end
end
