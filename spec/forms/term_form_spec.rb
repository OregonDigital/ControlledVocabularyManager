# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermForm do
  subject { described_class.new(vocabulary_form, repository) }

  let(:vocabulary_form) { VocabularyForm.new(term, Vocabulary) }
  let(:repository) { Vocabulary }
  let(:term) do
    t = Term.new('1/test')
    t.attributes = params
    t
  end
  let(:params) do
    {
      comment: ['Comment'],
      label: ['Label']
    }
  end
  let(:vocabulary_exists) { true }

  before do
    allow(term.class).to receive(:exists?).and_return(false)
    id_exists('1', vocabulary_exists)
  end

  def id_exists(id, exists = true)
    allow(term.class).to receive(:exists?).with(id).and_return(exists)
  end

  describe 'validations' do
    it 'is valid by default' do
      expect(subject).to be_valid
    end
    context 'when the id is blank' do
      let(:term) do
        t = Term.new('1/')
        t.attributes = params
        t
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:id]).to include "can't be blank"
      end
    end

    context "when the vocabulary doesn't exist" do
      let(:vocabulary_exists) { false }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:id]).to include 'is in a non existent vocabulary'
      end
    end

    context 'when the id already exists' do
      before do
        allow(Vocabulary).to receive(:exists?).with('1').and_return(false)
        allow(Vocabulary).to receive(:exists?).with('1/test').and_return(true)
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
      it 'allows multiple messages' do
        subject.valid?
        expect(subject.errors[:id].length).to be > 0
      end
    end
  end
end
