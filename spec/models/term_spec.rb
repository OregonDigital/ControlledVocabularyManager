# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Term do
  let(:uri) { 'http://opaquenamespace.org/ns/bla' }
  let(:resource) { described_class.new(uri) }

  it 'is an AT::Resource' do
    expect(described_class < ActiveTriples::Resource).to be true
  end

  it 'instantiates' do
    expect { described_class.new }.not_to raise_error
  end

  context 'when it is persisted' do
    before do
      resource.comment = 'This is a comment'
      resource.persist!
    end

    it 'is retrievable' do
      expect(described_class.find(uri)).not_to be_empty
    end
  end

  describe '#deprecated?' do
    context 'when it is deprecated' do
      before do
        resource.is_replaced_by = 'test'
      end

      it 'returns true' do
        expect(resource.deprecated?).to be true
      end
    end

    context 'when it is active' do
      before do
        resource.is_replaced_by = []
      end

      it 'returns true' do
        expect(resource.deprecated?).to be false
      end
    end
  end

  describe '#deprecated_vocab?' do
    context 'when vocabulary is deprecated' do
      before do
        resource.type = Vocabulary.type
        resource.is_replaced_by = ['test']
        resource.persist!
      end

      it 'returns true' do
        expect(resource.deprecated_vocab?).to be true
      end
    end

    context 'when vocabulary is active' do
      before do
        resource.type = Vocabulary.type
        resource.is_replaced_by = []
        resource.persist!
      end

      it 'returns true' do
        expect(resource.deprecated_vocab?).to be false
      end
    end
  end

  describe '#fields' do
    it 'returns all available fields' do
      expect(resource.fields).to include(:comment, :modified, :label, :issued)
    end
  end

  describe '#editable_fields' do
    it 'returns all fields except issued/modified' do
      expect(resource.editable_fields).to eq resource.fields - %i[issued modified is_replaced_by]
      expect(resource.editable_fields).not_to include(:issued, :modified, :is_replaced_by)
    end
  end

  describe '#editable_fields_deprecate' do
    it 'returns is_replaced_by field' do
      expect(resource.editable_fields_deprecate).to include(:is_replaced_by)
    end
  end

  describe '#term_uri' do
    it 'returns the parent URI' do
      expect(resource.term_uri.uri).to eq uri
    end
  end

  describe '#get_values' do
    before do
      resource.comment = 'test'
    end

    it 'is able to return values' do
      expect(resource.get_values(:comment)).to eq ['test']
    end
  end

  describe '#attributes=' do
    context 'with blank arrays' do
      let(:attributes) do
        {
          label: [],
          comment: ['bla']
        }
      end

      before do
        resource.attributes = attributes
      end

      it 'does nothing' do
        expect(resource.label).to eq []
        expect(resource.comment).to eq ['bla']
      end
    end
  end

  describe '#exists?' do
    let(:result) { described_class.exists?('bla') }

    context 'when it is in the repository' do
      before do
        resource.comment = ['bla']
        resource.persist!
      end

      it 'is true' do
        expect(result).to eq true
      end
    end
  end

  describe '#vocabulary?' do
    context 'when it is a term' do
      it 'is not a vocabulary' do
        expect(resource).not_to be_vocabulary
      end
    end

    context 'when it has a vocabulary type' do
      before do
        resource.type = Vocabulary.type
      end

      it 'is a vocabulary' do
        expect(resource).to be_vocabulary
      end
    end
  end

  describe 'validations' do
    context 'when not given a uri' do
      let(:uri) { nil }

      it 'is invalid' do
        expect(resource).not_to be_valid
      end
    end

    context 'when given a URI' do
      it 'is valid' do
        expect(resource).to be_valid
      end
    end
  end

  describe '.base_uri' do
    it 'is set to the app domain' do
      expect(resource.class.base_uri).to eq "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
    end
  end

  describe '#id' do
    context 'with no id' do
      let(:resource) { described_class.new }

      it 'is nil' do
        expect(resource.id).to be_nil
      end
    end

    context 'with an id' do
      let(:resource) { described_class.new('bla/bla') }

      before do
        resource.persist!
      end

      it 'is just the id' do
        expect(resource.id).to eq 'bla/bla'
      end
    end
  end

  describe '#values_for_property' do
    context "When requesting a property's values when 1 value is present." do
      let(:label) { RDF::Literal('blah', language: :en) }
      let(:resource) do
        t = described_class.new('1')
        t.label = [label]
        t
      end

      it 'returns the value in array form' do
        expect(resource.values_for_property(:label)).to eq ['blah']
      end
    end

    context "When requesting a property's values when multiple values are present" do
      let(:label1) { RDF::Literal('blah', language: :en) }
      let(:label2) { RDF::Literal('banana', language: :zu) }
      let(:resource) do
        t = described_class.new('1')
        t.label = [label1, label2]
        t
      end

      it 'returns the list of values' do
        expect(resource.values_for_property(:label)).to eq %w[blah banana]
      end
    end
  end

  describe '#literal_language_list_for_property' do
    context 'When requesting a literal with a language for a property' do
      let(:label) { RDF::Literal('blah', language: :en) }
      let(:resource) do
        t = described_class.new('1')
        t.label = [label]
        t
      end

      it 'returns the literal and language' do
        expect(resource.literal_language_list_for_property(:label).first.first).to be_kind_of RDF::Literal
        expect(resource.literal_language_list_for_property(:label).first.second).to eq 'English'
      end
    end

    context 'When requesting a list of literals with languages' do
      let(:label1) { RDF::Literal('blah', language: :en) }
      let(:label2) { RDF::Literal('banana', language: :zu) }
      let(:resource) do
        t = described_class.new('1')
        t.label = [label1, label2]
        t
      end

      it 'returns the list' do
        expect(resource.values_for_property(:label)).to eq %w[blah banana]
      end
    end
  end

  describe '#language_from_symbol' do
    it 'returns a string from a language symbol' do
      expect(resource.language_from_symbol(:zu)).to eq 'Zulu'
    end
  end

  describe 'self.class_from_types' do
    let(:types) { [type, RDF::URI('https://www.w3.org/2000/01/rdf-schema#Resource')] }

    [Vocabulary, Predicate, CorporateName, Geographic, Title, Topic, PersonalName, described_class, LocalCollection].each do |k|
      context "when passing a #{k} type" do
        let(:type) { k.type }

        it "returns the #{k} class" do
          expect(TermType.class_from_types(types)).to eq k
        end
      end
    end
  end
end
