# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeprecateTermForm do
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
    it 'is not valid by default' do
      expect(subject).not_to be_valid
      expect(subject).not_to be_is_valid
    end

    context 'when is_replaced_by is blank' do
      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:is_replaced_by]).to include "can't be blank"
      end
    end

    context 'when is_replaced_by is valid' do
      let(:params) do
        {
          comment: ['Comment'],
          label: ['Label'],
          is_replaced_by: ['http://bla.com/']
        }
      end

      it 'is valid' do
        expect(subject).to be_valid
        expect(subject).to be_is_valid
        expect(subject.errors[:is_replaced_by]).not_to include "can't be blank"
      end
    end

    context 'when is_replaced_by is invalid' do
      let(:params) do
        {
          comment: ['Comment'],
          label: ['Label'],
          is_replaced_by: ['bla']
        }
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:is_replaced_by]).to include 'invalid uri'
      end
    end

    context "when the vocabulary doesn't exist" do
      let(:vocabulary_exists) { false }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:id]).to include 'is in a non existent vocabulary'
      end
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:params) do
        {
          comment: ['Comment'],
          label: ['Label'],
          is_replaced_by: ['http://bla.com/']
        }
      end

      it 'returns true' do
        expect(subject.save).to eq true
      end
    end

    context 'when invalid' do
      let(:id) { '' }

      it 'returns false' do
        expect(subject.save).to eq false
      end
    end
  end
end
