# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecoratorList do
  subject { described_class.new(decorator_1, decorator_2) }

  let(:decorator_1) { double('decorator') }
  let(:decorator_2) { double('decorator_2') }

  describe '#new' do
    let(:object) { double('object') }
    let(:result) { subject.new(object) }

    before do
      allow(decorator_1).to receive(:new).with(object).and_return(decorator_1)
      allow(decorator_2).to receive(:new).with(decorator_1).and_return(decorator_2)
    end

    it 'decorates everything' do
      expect(result).to eq decorator_2
      expect(decorator_1).to have_received(:new)
      expect(decorator_2).to have_received(:new)
    end
  end
end
