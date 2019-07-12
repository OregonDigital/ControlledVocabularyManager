# frozen_string_literal: true

##
# Value object representing a URI for Terms.
#
# This encapsulates the logic for getting the ending ID of a term even if it's
# in a vocabulary. It doesn't work in all use cases - only for our URI formats.
class TermUri
  attr_reader :uri
  def initialize(uri)
    @uri = uri
  end

  def leaf
    if uri.node? || uri.ends_with?("/")
      ""
    else
      uri.to_s.gsub(uri.parent.to_s, '')
    end
  end

  def vocabulary_uri
    if uri.ends_with?("/")
      vocab_uri = RDF::URI.new(uri.to_s.gsub(/\/$/,''))
    else
      vocab_uri = RDF::URI.new(uri.parent.to_s.gsub(/\/$/,''))
    end
    TermUri.new(vocab_uri)
  end

  def vocabulary_id
    vocabulary_uri.leaf
  end

end
