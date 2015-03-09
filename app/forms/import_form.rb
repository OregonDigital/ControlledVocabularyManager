class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview

  validates_presence_of :url

  def preview?
    preview == "1"
  end
end
