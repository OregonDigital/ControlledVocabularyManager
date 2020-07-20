# frozen_string_literal: true

require 'rails_helper'
require 'terms_are_importable'

RSpec.describe ImportableTerm do
  let(:term) { Term.new(term_id2) }
  let(:term_id2) { 'I_exist' }
  let(:term_id) { 'blah' }
  let(:list2) { ImportableTermList.new([Term.new(term_id2)]) }
  let(:list) { ImportableTermList.new([Term.new(term_id)]) }
  let(:validator) { TermsAreImportable.new }

  xit 'should not validate with TermIsUnique' do
    expect(described_class.validators).not_to include TermIsUnique
  end

  context 'when a term in the list already exists' do
    before do
      term.persist!
    end

    it 'allows the unique term' do
      validator.validate(list)
      expect(list.errors.size).to be 0
    end

    it 'fails the duplicate term' do
      validator.validate(list2)
      expect(list2.errors.messages.to_s).to include('Id already exists')
    end
  end
end
