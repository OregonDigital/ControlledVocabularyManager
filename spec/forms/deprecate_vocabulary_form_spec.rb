# frozen_string_literal: true

require 'rails_helper'

WebMock.allow_net_connect!

RSpec.describe DeprecateVocabularyForm do
  subject { described_class.new(term, repository) }

  let(:term) do
    t = Vocabulary.new(id)
    t.attributes = params
    t
  end
  let(:repository) { Vocabulary }
  let(:id) { 'term' }
  let(:params) do
    {
      comment: ['Comment'],
      label: ['Label'],
      is_replaced_by: ['http://bla.com/']
    }
  end

  def id_exists(id, exists = true)
    allow(term.class).to receive(:exists?).with(id).and_return(exists)
  end

  def stub_term_factory
    allow(term).to receive(:attributes=)
    allow(term).to receive(:is_replaced_by=)
    allow(term).to receive(:fields).and_return(%i[comment label is_replaced_by])
    term
  end

  describe '#editable_fields' do
    it 'delegates to Term' do
      term = stub_term_factory
      allow(term).to receive(:editable_fields).and_return([:label])

      expect(subject.editable_fields).to eq [:label]
    end
  end

  describe 'validations' do
    before do
      id_exists(id, false)
    end

    it 'is valid by default' do
      expect(subject).to be_valid
      expect(subject).to be_is_valid
    end

    context 'when the term already exists' do
      before do
        id_exists(id)
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:id]).to include 'already exists in the repository'
      end
    end

    context 'when the id is blank' do
      let(:id) { '' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:id]).to include "can't be blank"
      end
    end

    context 'when is_replaced_by is blank' do
      let(:params) do
        {
          comment: ['Comment'],
          label: ['Label'],
          is_replaced_by: []
        }
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject).not_to be_is_valid
        expect(subject.errors[:is_replaced_by]).to include "can't be blank"
      end
    end
  end

  describe '#save' do
    context 'when valid' do
      before do
        id_exists(id, false)
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
