# frozen_string_literal: true

require 'rails_helper'
# this test is kind of obsolete? but fixing it anyway
RSpec.describe StandardRepository do
  subject { described_class.new(decorators, Term) }

  let(:decorators) {}

  describe '#new' do
    let(:result) { subject.new(id) }
    let(:id) { 'vocab/1' }

    context 'when given no decorators' do
      it 'is a term' do
        expect(result).to be_instance_of Term
      end
    end
  end
end
