# frozen_string_literal: true

require 'rails_helper'
require 'term_is_sanitary'

RSpec.describe TermIsSanitary do
  let(:term_id) { 'bogus name' }
  let(:record) { Term.new(term_id) }
  let(:validator) { described_class.new }

  it 'has more than one error' do
    validator.validate(record)
    expect(record.errors.size).to be > 0
  end
  describe 'a term with a space in the id' do
    it 'fails validation with an appropriate error' do
      validator.validate(record)
      expect(record.errors[:id].first).to include('Term contains spaces')
    end
  end

  describe 'a term with invalid UTF8 in the id, urlencoded when posted by the form' do
    let(:term_id) { '\\xE4\\xF6\\xFC\\xDF' }

    it 'fails validation with an appropriate error' do
      validator.validate(record)
      expect(record.errors[:id].first).to include('Term contains special characters')
    end
  end
end
