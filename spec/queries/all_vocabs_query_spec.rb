require 'rails_helper'

RSpec.describe AllVocabsQuery do
  let(:sparql_client) { vocabulary.repository.query_client }
  let(:vocabulary) { SetsIssued.new(Vocabulary.new("bla")) }
  describe ".call" do
    context "when vocabularies exist" do
      let(:vocabulary) { SetsIssued.new(Vocabulary.new("bla")) }
      let(:sparql_client) { vocabulary.repository.query_client }
      let(:repository) { VocabularyInjector.new.vocabulary_repository }
      before do
        vocabulary.label = "YO"
        vocabulary.persist!
      end
      it "should return all vocabularies" do
        expect(described_class.call(sparql_client, repository)).to eq [vocabulary.__getobj__]
      end
      it "should not return terms" do
        repository.new("2/1").persist!
        expect(described_class.call(sparql_client, repository)).to eq [vocabulary.__getobj__]
      end
      context "when given a limit" do
        subject { described_class.call(sparql_client, repository, :limit => 1) }
        let(:vocabulary_2) { SetsIssued.new(Vocabulary.new("bla2")) }
        before do
          vocabulary_2.persist!
        end
        it "should only return that many" do
          expect(subject).to eq [vocabulary.__getobj__]
        end
        context "when given an offset" do
          # This is a marmotta bug - it NEEDS a non-0 limit to use offset.
          subject { described_class.call(sparql_client, repository, :offset => 1, :limit => 10000000) }
          it "should return that one" do
            expect(subject).to eq [vocabulary_2.__getobj__]
          end
        end
      end
    end
  end

  describe "#limit" do
    subject { described_class.new(sparql_client) }
    it "should set limit" do
      result = subject.limit(1)

      expect(result.options[:limit]).to eq 1
    end
  end

  describe "#offset" do
    subject { described_class.new(sparql_client) }
    it "should set offset" do
      result = subject.offset(1)

      expect(result.options[:offset]).to eq 1
    end
  end
end
