# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Predicate do
  let(:uri) { 'http://opaquenamespace.org/ns/bla' }
  let(:resource) { described_class.new(uri) }
  let(:resource_with_children) { TermWithChildren.new(resource, ChildNodeFinder) }
  let(:children) { [] }
  let(:id) { nil }

  # This test validates the issued/modified behavior
  it 'is a subclass of Term' do
    expect(described_class < Term).to be true
  end

  it 'has a configured type' do
    expect(resource.type).to eq [RDF::URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate')]
  end

  it 'has visible form fields' do
    expect(described_class.visible_form_fields).to eq %w[label alternate_name date comment is_replaced_by see_also is_defined_by same_as modified issued title publisher sub_property_of range domain]
  end

  it 'has additional fields' do
    expect(resource.fields).to include :sub_property_of
    expect(resource.fields).to include :range
    expect(resource.fields).to include :domain
  end
end
