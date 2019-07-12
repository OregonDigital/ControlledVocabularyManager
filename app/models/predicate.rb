# frozen_string_literal: true

# Predicate
class Predicate < Term
  configure type: RDF::URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate')
  property :sub_property_of, predicate: RDF::RDFS.subPropertyOf
  property :range, predicate: RDF::RDFS.range
  property :domain, predicate: RDF::RDFS.domain

  validates_with ValidUri

  Sunspot::Adapters::InstanceAdapter.register(SunspotHelper::InstanceAdapter, Predicate)
  Sunspot::Adapters::DataAccessor.register(SunspotHelper::DataAccessor, Predicate)

  Sunspot.setup(Predicate) do
    text :id, boost: 2.0
    text :label, boost: 2.0
    text :comment, stored: true

    string :id, stored: true
    string :label, stored: true, multiple: true
  end

  def self.option_text
    'Predicate'
  end

  def self.uri
    type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by see_also is_defined_by same_as modified issued title publisher sub_property_of range domain]
  end

  # Update the fields method with any new properties added to this model
  def fields
    %i[sub_property_of range domain] | super - %i[ark local]
  end
end
