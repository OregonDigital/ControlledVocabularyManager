# Term Type hash and utility methods to drive the term type select list and aid
# in rendering of term#show and index pages
class TermType

  # Key names relate to models which inherit from Term that are considered to be
  # different 'types' of terms.. (not a vocabulary)
  def self.models
    self.terms.keys
  end

  # Clear names for use with labels on views
  def self.names
    self.terms.values.map { |x| x[0] }
  end

  # Given the key/model name, get its url
  def self.url_for(key)
    self.terms[key][1]
  end

  # Terms (any type) and Vocabulary instances from the triplestore have the type
  # stored as an RDF::URI, this method returns a clear name for the uri or to
  # call it a Vocabulary when using the show view of a vocabulary
  def self.name_for(url)
    if self.vocabulary?(url)
      "Vocabulary"
    else
      found = self.terms.values.find { |x| x[1] == url }
      found[0]
    end
  end

  def self.vocabulary?(url)
    url == "http://purl.org/dc/dcam/VocabularyEncodingScheme"
  end

  # The map of Model => [Name, URL]
  def self.terms
    {
      "Term" => ["Generic Term", ""],
      "Concept" => ["Concept","http://www.w3.org/2004/02/skos/core#Concept"],
      "CorporateName" => ["Corporate Name","http://www.w3.org/2004/02/skos/core#CorporateName"],
      "Geographic" => ["Geographic","http://www.w3.org/2004/02/skos/core#Geographic"],
      "PersonalName" => ["Personal Name","http://www.w3.org/2004/02/skos/core#PersonalName"],
      "Title" => ["Title","http://www.w3.org/2004/02/skos/core#Title"],
      "Topic" => ["Topic","http://www.w3.org/2004/02/skos/core#Topic"]
    }
  end
end
