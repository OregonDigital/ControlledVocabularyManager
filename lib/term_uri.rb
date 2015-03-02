class TermUri
  attr_reader :uri
  def initialize(uri)
    @uri = uri
  end

  def leaf
    if uri.ends_with?("/")
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
