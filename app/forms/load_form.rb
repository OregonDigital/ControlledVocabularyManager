# frozen_string_literal: true

# Load RDF Form
class LoadForm
  include ActiveModel::Model
  attr_accessor :rdf_string, :term_list, :rdf_importer_factory

  def initialize(rdf_string, rdf_importer_factory)
    @rdf_string = rdf_string
    @rdf_importer_factory = rdf_importer_factory
  end

  def valid?
    run
    errors.empty?
  end

  private

  def run
    return if term_list

    errors.clear
    @term_list = rdf_importer_factory.new(errors, rdf_string: rdf_string, validators: validators).run
  end

  def validators
    [IsValidRdfString]
  end
end
