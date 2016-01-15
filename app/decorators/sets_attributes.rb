class SetsAttributes < SimpleDelegator
  def set_languages(form_params)
    new_hash = {}
    self.attributes.each_pair do |key, value|
      unless key == "id" || key == "issued" || key == "modified"
        value_array = []
        value.each do |val|
          value_array << RDF::Literal(val, :language => form_params[key])
        end
        new_hash[key] = value_array
      end
    end
    self.attributes = new_hash
  end
end
