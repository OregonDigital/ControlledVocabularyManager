# frozen_string_literal: true

class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview, :term_list, :rdf_importer_factory

  def initialize(url, preview, rdf_importer_factory)
    @url = url
    @preview = preview
    @rdf_importer_factory = rdf_importer_factory
  end

  def preview?
    preview == '1'
  end

  def valid?
    run
    errors.empty?
  end

  private

  def run
    return if @term_list

    errors.clear
    @term_list = rdf_importer_factory.new(errors, url: url, validators: validators).run
  end

  def validators
    [IsValidRdfImportUrl]
  end
end
