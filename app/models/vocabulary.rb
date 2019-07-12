# frozen_string_literal: true

# Vocabulary
class Vocabulary < Term
  require 'sunspot'
  require 'sunspot_helper'

  validates_with ValidUri

  configure type: RDF::URI('http://purl.org/dc/dcam/VocabularyEncodingScheme')
  property :title, predicate: RDF::Vocab::DC.title
  property :publisher, predicate: RDF::Vocab::DC.publisher
  property :sub_property_of, predicate: RDF::RDFS.subPropertyOf
  property :range, predicate: RDF::RDFS.range
  property :domain, predicate: RDF::RDFS.domain

  Sunspot::Adapters::InstanceAdapter.register(SunspotHelper::InstanceAdapter, Vocabulary)
  Sunspot::Adapters::DataAccessor.register(SunspotHelper::DataAccessor, Vocabulary)

  Sunspot.setup(Vocabulary) do
    text :id
    text :label, using: :title, boost: 2.0
    text :comment, stored: true

    string :id, stored: true
    string :label, using: :title, stored: true, multiple: true
  end

  def self.option_text
    'Vocabulary'
  end

  def self.uri
    type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by see_also is_defined_by same_as modified issued title publisher sub_property_of range domain]
  end

  def allow_vocab_deprecate?
    deprecated_children.length == vocab_with_children.length
  end

  # Update the fields method with any new properties added to this model
  def fields
    %i[title publisher sub_property_of range domain] | super - %i[ark local]
  end

  private

  def deprecated_children
    vocab_with_children.select(&:deprecated?)
  end

  def vocab_with_children
    injector = TermInjector.new
    vocab = TermWithChildren.new(self, injector.child_node_finder)
    vocab.children
  end
end
