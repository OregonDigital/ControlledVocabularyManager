# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllVocabsQuery do
  describe ".call" do
    context "when vocabularies exist" do
      let(:vocabulary) { Vocabulary.new("bla") }
      let(:sparql_client) { VocabularyInjector.new.sparql_client }
      let(:repository) { VocabularyInjector.new.vocabulary_repository }
      before do
        vocabulary.label = "YO"
        vocabulary.persist!
      end
      it "should return all vocabularies" do
        expect(described_class.call(sparql_client, repository,Vocabulary.type)).to include(vocabulary)
      end
      let(:term) { Term.new("bla/1") }
      before do
        term.label = "GURT"
        term.persist!
      end
      it "should not return terms" do
        expect(described_class.call(sparql_client, repository,Vocabulary.type)).not_to include(term)
      end
      let(:predicate) {Predicate.new("mypred")}
      before do
        predicate.label = "Strawberry"
        predicate.persist!
      end
      it "should not return preds" do
        expect(described_class.call(sparql_client, repository,Vocabulary.type)).not_to include(predicate)
      end
    end
  end
end
