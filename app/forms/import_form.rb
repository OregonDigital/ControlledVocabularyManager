class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview, :term_list

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
    errors.clear
    @term_list = RdfImporter.new(errors, url).run
  end
end
