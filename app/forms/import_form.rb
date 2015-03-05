class ImportForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [:url, :preview]
  attr_accessor *ATTRIBUTES

  validates_presence_of :url

  def persisted?
    false
  end

  def preview?
    preview == "1"
  end

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
end
