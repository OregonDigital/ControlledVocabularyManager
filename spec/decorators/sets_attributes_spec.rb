# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetsAttributes do
  subject { described_class.new(term) }

  let(:term) { term_mock }
  let(:test_param) do
    {
      label: ['blah'],
      see_also: ['http://id.loc.gov/authorities/subjects/sh85145447'],
      language: {
        label: ['en']
      }
    }
  end

  before do
    stub_repository
    allow(term).to receive(:attributes=)
    allow(term).to receive(:attributes).and_return(test_param)
    allow(term).to receive(:blacklisted_language_properties).and_return(%i[id issued modified])
    allow(term).to receive(:valid?).and_return(true)
  end

  describe '#set_languages' do
    context 'when saving a term or vocab' do
      before do
        subject.set_languages(test_param)
      end

      it 'sets the attributes' do
        expect(term).to have_received(:attributes=)
      end
    end
  end
end
