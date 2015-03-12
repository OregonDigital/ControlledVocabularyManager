class IsValidRdfImportUrl < ActiveModel::Validator
  def validate(record)
    if record.url.blank?
      record.errors.add(:url, "can't be blank")
      return
    end

    begin
      uri = URI.parse(record.url)
    rescue
      record.errors.add(:url, "is not a URL")
      return
    end

    unless allowed_uri(uri)
      record.errors.add(:url, "is not an allowed RDF import URL")
    end
  end

  private

  # We only allow http and https for RDF importing from a web form
  def allowed_uri(uri)
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
