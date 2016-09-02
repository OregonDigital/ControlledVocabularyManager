class AddResource < SimpleDelegator
  def add_resource
    if valid?
      self.type << RDF::Statement(RDF::URI("http://opaquenamespace.org/ns/#{self.id}"),RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource"))
    end
  end
end

