# frozen_string_literal: true

class IsValidRdfImportUrl < ActiveModel::Validator
  def validate(record)
    if record.url.blank?
      record.errors.add(:url, "can't be blank") if record.url.blank?
      record.errors.add(:base, "URL cannot be blank.") if record.url.blank?
      return
    end

    begin
      uri = URI.parse(record.url.to_s)
    rescue
      record.errors.add(:url, "is not a URL")
      record.errors.add(:base, "URL is not valid.")
      return
    end

    unless allowed_uri(uri)
      record.errors.add(:url, "is not an allowed RDF import URL")
      record.errors.add(:base, "URL is not allowed for import.")
    end
  end

  private

  # We only allow http and https for RDF importing from a web form
  def allowed_uri(uri)
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
