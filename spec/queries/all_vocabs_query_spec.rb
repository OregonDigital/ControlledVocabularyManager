require 'rails_helper'

RSpec.describe AllVocabsQuery do
  describe ".call" do
    context "when vocabularies exist" do
      let(:vocabulary) { Vocabulary.new("bla") }
      let(:sparql_client) { vocabulary.repository.query_client }
      before do
        vocabulary.label = "YO"
        vocabulary.persist!
      end
      it "should return all vocabularies" do
        expect(described_class.call(sparql_client)).to eq [vocabulary]
      end
      it "should not return terms" do
        Term.new("2").persist!
        expect(described_class.call(sparql_client)).to eq [vocabulary]
      end
    end
  end
end
