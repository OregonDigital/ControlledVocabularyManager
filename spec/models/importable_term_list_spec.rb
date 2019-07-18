# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportableTermList do
  let(:vocabulary) { Vocabulary.new('vocab') }
  let(:term1) { Term.new('vocab/one') }
  let(:term2) { Term.new('vocab/two') }
  let(:terms) { [vocabulary, term1, term2] }
  let(:termlist) { described_class.new(terms) }

  before do
    allow(Term).to receive(:exists?).and_return(false)
  end

  describe 'when checking validations' do
    context 'and a term is in the list more than once' do
      let(:terms) { [vocabulary, term1, term2, term2] }

      it 'reports a duplicate item in the list' do
        expect(termlist.valid?).to eq(false)
        expect(termlist.errors.count).to eq(1)
        expect(termlist.errors[:base].first).to match(%r{vocab/two})
        expect(termlist.errors[:base].first).to match(/already exists/)
      end
    end

    context 'and a term in the list is missing an id' do
      let(:terms) { [vocabulary, term1, term2, Term.new] }

      it 'reports the missing id' do
        expect(termlist.valid?).to eq(false)
        expect(termlist.errors.count).to eq(1)
        expect(termlist.errors[:base].first).to match(/id can't be blank/i)
      end
    end
  end

  describe '#save' do
    # Make sure we don't typo this and end up with silent false positives :-/
    let(:save) { :persist! }

    context 'when the term list is valid' do
      before do
        allow(termlist).to receive(:valid?).and_return(true)
      end

      it 'saves each term' do
        terms.each { |term| expect(term).to receive(save) }
        termlist.save
      end

      it 'does not return false' do
        expect(termlist.save).not_to eq(false)
      end
    end

    context "when the term list isn't valid" do
      before do
        allow(termlist).to receive(:valid?).and_return(false)
      end

      it 'does not save any terms' do
        terms.each { |term| expect(term).not_to receive(save) }
        termlist.save
      end

      it 'returns false' do
        expect(termlist.save).to eq(false)
      end
    end
  end
end
