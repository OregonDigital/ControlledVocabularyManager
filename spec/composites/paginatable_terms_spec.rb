require 'rails_helper'

RSpec.describe PaginatableTerms do
  subject { described_class.new(query).page(page).per(limit) }
  let(:injector) { VocabularyInjector.new }
  let(:query) { injector.__send__(:all_vocabs_query_client) }
  let(:page) { 1 }
  let(:limit) { 10 }
  before do
    stub_repository
  end
  describe "#limit_value" do
    it "should be the configured value" do
      expect(subject.limit_value).to eq limit
    end
  end

  describe "#offset_value" do
    context "when page is 1" do
      it "should be 0" do
        expect(subject.offset_value).to eq 0
      end
    end
    context "when page is 2" do
      let(:page) { 2 }
      it "should be 10" do
        expect(subject.offset_value).to eq limit
      end
    end
  end

  describe "#entry_name" do
    it "should be term" do
      expect(subject.entry_name).to eq "term"
    end
  end

  describe "#each" do
    context "when there are no vocabularies" do
      it "should be []" do
        expect(subject.each.to_a).to eq []
      end
    end
    def create_vocab(id)
      v = Vocabulary.new(id)
      v.persist!
      v
    end
    context "when there are vocabularies" do
      let(:vocabulary_1) { create_vocab("1") }
      let(:vocabulary_2) { create_vocab("2") }
      before do
        vocabulary_1
        vocabulary_2
      end
      it "should return them" do
        expect(subject.each.to_a).to eq [vocabulary_1, vocabulary_2]
      end
      context "and page is set" do
        let(:limit) { 1 }
        let(:page) { 2 }
        it "should page" do
          expect(subject.each.to_a).to eq [vocabulary_2]
        end
      end
    end
    
    describe "#total_count" do
      context "when there are vocabularies" do
        let(:vocabulary_1) { create_vocab("1") }
        let(:vocabulary_2) { create_vocab("2") }
        let(:vocabulary_3) { create_vocab("3") }
        before do
          vocabulary_1
          vocabulary_2
          vocabulary_3
        end
        it "should return the total count" do
          expect(subject.total_count).to eq 3
        end
        context "and it's paginating" do
          let(:limit) { 1 }
          let(:page) { 2 }
          it "should return the total count" do
            expect(subject.total_count).to eq 3
          end
        end
      end
    end
  end
end
