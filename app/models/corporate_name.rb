# frozen_string_literal: true

# Corporate Name Term Type
class CorporateName < Term
  configure type: RDF::URI('http://www.w3.org/2004/02/skos/core#CorporateName')

  def self.option_text
    'Corporate Name'
  end

  def self.uri
    type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by is_defined_by same_as modified issued]
  end
end
