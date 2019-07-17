# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermType do
  it 'returns 7 models' do
    expect(described_class.models.length).to eq(7)
  end
  it 'returns 7 names' do
    expect(described_class.names.length).to eq(7)
  end
  it "shows all models having field 'date'" do
    expect(described_class.models_having_visible_property('date').length).to eq(7)
  end

  # Run through all of the TermType related models as well as Vocabulary and Predicate
  described_class.models.concat(%w[Vocabulary Predicate]).each do |m|
    context "when evaluating #{m}" do
      let(:klass) { m.constantize }
      let(:term) { klass.new }

      if m == 'Vocabulary'
        it 'is a Vocabulary' do
          expect(described_class).to be_vocabulary(term.type[0].to_s)
          expect(described_class).not_to be_predicate(term.type[0].to_s)
        end
      elsif m == 'Predicate'
        it 'is a Predicate' do
          expect(described_class).not_to be_vocabulary(term.type[0].to_s)
          expect(described_class).to be_predicate(term.type[0].to_s)
        end
      else
        it 'is not a Vocabulary or a Predicate' do
          expect(described_class).not_to be_vocabulary(term.type[0].to_s)
          expect(described_class).not_to be_predicate(term.type[0].to_s)
        end
      end

      it 'returns its name' do
        expect(described_class.name_for(term.type[0].to_s)).to eq(klass.option_text)
      end

      it 'returns its url' do
        expect(described_class.url_for(m)).to eq(klass.uri)
      end

      it 'returns the proper class' do
        expect(described_class.class_from_types(term.type)).to eq(klass)
      end
    end
  end
end
