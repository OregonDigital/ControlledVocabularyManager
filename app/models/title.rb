# frozen_string_literal: true

class Title < Term
  configure type: RDF::URI('http://www.w3.org/2004/02/skos/core#Title')

  def self.option_text
    'Title'
  end

  def self.uri
    type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by is_defined_by same_as modified issued]
  end
end
