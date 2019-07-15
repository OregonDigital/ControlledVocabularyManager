# frozen_string_literal: true

# Maybe URI object
class MaybeURI
  pattr_initialize :raw_value

  def value
    if uri?
      uri
    else
      raw_value
    end
  end

  def uri?
    String === raw_value && !uri.scheme.blank? && !uri.host.blank? && !uri.invalid?
  end

  private

  def uri
    @uri ||= RDF::URI(raw_value)
  end
end
