class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview

  validates_with IsValidRdfImportUrl

  def preview?
    preview == "1"
  end
end
