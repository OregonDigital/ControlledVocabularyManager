# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetsIssued do
  subject { described_class.new(term) }

  let(:term) { term_mock }

  before do
    stub_repository
    allow(term).to receive(:issued=)
    # allow(term).to receive(:persist!)
    allow(term).to receive(:valid?).and_return(true)
    allow(term).to receive(:new_record?).and_return(true)
  end

  describe '#set_issued' do
    context "when it's issued" do
      before do
        subject.set_issued
      end

      it 'sets issued to current day' do
        expect(term).to have_received(:issued=).with(RDF::Literal::Date.new(Time.now))
      end
    end

    context 'when not valid' do
      before do
        allow(term).to receive(:valid?).and_return(false)
        subject.set_issued
      end

      it 'does not set issued' do
        expect(term).not_to have_received(:issued=)
      end
    end

    context 'when not a new record' do
      before do
        allow(term).to receive(:new_record?).and_return(false)
        subject.set_issued
      end

      it 'does not set issued' do
        expect(term).not_to have_received(:issued=)
      end
    end
  end
end
