# frozen_string_literal: true

class AddResource < SimpleDelegator
  def persist!
    add_resource
    __getobj__.persist!
  end

  def add_resource
    if valid?
      get_values(:type) << RDF::URI('http://www.w3.org/2000/01/rdf-schema#Resource')
    end
  end
end
