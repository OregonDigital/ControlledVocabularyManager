class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview, :rdf_importer
  delegate :term_list, :to => :rdf_importer

  def initialize(params = {})
    super(params)
    @rdf_importer = RdfImporter.new(errors)
  end

  def preview?
    preview == "1"
  end

  def valid?
    run
    errors.empty?
  end

  def save
    return false unless valid?
    return true if preview?
    term_list.save
  end

  private

  def run
    return if term_list
    @rdf_importer.call(url)
  end
end
