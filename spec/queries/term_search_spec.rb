require 'rails_helper'

RSpec.describe TermSearch do
  subject { TermSearch.new(sparql_client) }
  let(:sparql_client) { Term.new.repository.query_client }

  describe "#search" do
    let(:query) { "banana" }
    let(:results) { subject.search(query) }
    context "when there are no results" do
      it "should return a blank array" do
        expect(results).to eq []
      end
    end
    context "when there are results" do
      let(:term) do
        t = Term.new("vocab/id")
        t.label = "ababananarama"
        t.persist!
        t
      end
      before do
        term
      end
      it "should return it" do
        expect(results).to eq [term]
      end
      context "which are vocabularies" do
        let(:term) do
          t = Vocabulary.new("id")
          t.label = "banana"
          t.persist!
          t
        end
        it "should return a vocabulary" do
          expect(results).to eq [term]
          expect(results.first).to be_kind_of Vocabulary
        end
      end
    end
  end
end
