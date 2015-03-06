require 'rails_helper'

RSpec.describe ImportableTermList do
  let(:vocabulary) { Vocabulary.new("vocab") }
  let(:term1) { Term.new("vocab/one") }
  let(:term2) { Term.new("vocab/two") }
  let(:terms) { [vocabulary, term1, term2] }
  let(:termlist) { ImportableTermList.new(terms) }

  describe "when checking validations" do
    context "and a term is already in the repository" do
      before do
        dupeterm1 = Term.new(term1.id)
        dupeterm1.persist!
      end

      it "should report that term 'vocab/one' already exists" do
        expect(termlist.valid?).to eq(false)
        expect(termlist.errors.count).to eq(1)
        expect(termlist.errors[:base].first).to match(%r|vocab/one|)
        expect(termlist.errors[:base].first).to match(%r|already exists|)
      end
    end

    context "and a term is in the list more than once" do
      let(:terms) { [vocabulary, term1, term2, term2] }

      it "should report a duplicate item in the list" do
        expect(termlist.valid?).to eq(false)
        expect(termlist.errors.count).to eq(1)
        expect(termlist.errors[:base].first).to match(%r|vocab/two|)
        expect(termlist.errors[:base].first).to match(%r|already exists|)
      end
    end

    context "and a term in the list is missing an id" do
      let(:terms) { [vocabulary, term1, term2, Term.new] }

      it "should report the missing id" do
        expect(termlist.valid?).to eq(false)
        expect(termlist.errors.count).to eq(1)
        expect(termlist.errors[:base].first).to match(%r|id can't be blank|i)
      end
    end
  end

  describe "#save" do
    # Make sure we don't typo this and end up with silent false positives :-/
    let(:save) { :persist! }

    context "when the term list is valid" do
      before do
        allow(termlist).to receive(:valid?).and_return(true)
      end

      it "should save each term" do
        terms.each {|term| expect(term).to receive(save)}
        termlist.save
      end

      it "should not return false" do
        expect(termlist.save).not_to eq(false)
      end
    end

    context "when the term list isn't valid" do
      before do
        allow(termlist).to receive(:valid?).and_return(false)
      end

      it "shouldn't save any terms" do
        terms.each {|term| expect(term).not_to receive(save)}
        termlist.save
      end

      it "should return false" do
        expect(termlist.save).to eq(false)
      end
    end
  end
end
