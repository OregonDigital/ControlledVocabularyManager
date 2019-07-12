# frozen_string_literal: true

# Term Type hash and utility methods to drive the term type select list and aid
# in rendering of term#show and index pages
class TermType
  # names relate to models which inherit from Term that are considered to be
  # different 'types' of terms.. (not a vocabulary)
  def self.models
    %w[Term CorporateName Geographic PersonalName Title Topic LocalCollection]
  end

  # Clear names for use with labels on views
  def self.names
    models.map { |x| x.constantize.option_text }
  end

  # Given the key/model name, get its url
  def self.url_for(model)
    model.constantize.uri
  end

  # return the name of each model which has the property_name set as visible
  def self.models_having_visible_property(property_name)
    models.select { |x| x.constantize.visible_form_fields.include?(property_name.to_s) }
  end

  # Terms (any type) and Vocabulary instances from the triplestore have the type
  # stored as an RDF::URI, this method returns a clear name for the uri or to
  # call it a Vocabulary when using the show view of a vocabulary
  def self.name_for(url)
    if vocabulary?(url)
      Vocabulary.option_text
    elsif predicate?(url)
      Predicate.option_text
    else
      found = models.find { |x| x.constantize.uri == url }
      found.constantize.option_text
    end
  end

  def self.vocabulary?(uri)
    uri == Vocabulary.uri
  end

  def self.predicate?(uri)
    uri == Predicate.uri
  end

  ##
  # Determine which class the Term is give an array of types passed in. This works in conjunction with PolymorphicTermRepository
  # for hydrating a type of a term from the triplestore backend.
  #
  # @param types [Array<RDF::URI>] the types coming from the backend query
  # @return [Class] the class which relates to the term queried
  def self.class_from_types(types)
    all_models = %w[Vocabulary Predicate]
    all_models.concat(models - ['Term'])

    all_models.each do |m|
      return m.constantize if types.include?(*Array(m.constantize.type))
    end

    # always default to Term last because it is the base class which others inherit from, this is tied to skos:Concept
    Term
  end
end
