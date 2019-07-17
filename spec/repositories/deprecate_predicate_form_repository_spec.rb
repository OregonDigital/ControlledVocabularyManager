# frozen_string_literal: true

require 'rails_helper'
# this test is kind of obsolete? but fixing it anyway
RSpec.describe DeprecatePredicateFormRepository do
  subject { described_class.new(decorators, Predicate) }

  let(:decorators) {}

  describe '#new' do
    it 'is have a decorating repository' do
      expect(subject.repository).to be_instance_of DecoratingRepository
    end
  end
end
