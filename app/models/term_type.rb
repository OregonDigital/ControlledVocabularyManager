# Term Type hash and utility methods to drive the term type select list and aid
# in rendering of term#show and index pages
class TermType

  # names relate to models which inherit from Term that are considered to be
  # different 'types' of terms.. (not a vocabulary)
  def self.models
    %w[Term Concept CorporateName Geographic PersonalName Title Topic]
  end

  # Clear names for use with labels on views
  def self.names
    self.models.map { |x| x.constantize.option_text }
  end

  # Given the key/model name, get its url
  def self.url_for(model)
    model.constantize.uri
  end

  # return the name of each model which has the property_name set as visible
  def self.models_having_visible_property(property_name)
    self.models.select { |x| x.constantize.visible_form_fields.include?(property_name.to_s) }
  end
  # Terms (any type) and Vocabulary instances from the triplestore have the type
  # stored as an RDF::URI, this method returns a clear name for the uri or to
  # call it a Vocabulary when using the show view of a vocabulary
  def self.name_for(url)
    if self.vocabulary?(url)
      Vocabulary.option_text
    else
      found = self.models.find { |x| x.constantize.uri == url }
      found.constantize.option_text
    end
  end

  def self.vocabulary?(uri)
    uri == Vocabulary.uri
  end
end
