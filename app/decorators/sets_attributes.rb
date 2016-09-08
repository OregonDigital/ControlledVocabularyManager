class SetsAttributes < SimpleDelegator
  def set_languages(form_params)
    new_hash = {}
    self.attributes.each_pair do |key, value|
      unless self.blacklisted_language_properties.include?(key.to_sym) 
        value_array = []
        value.each_with_index do |val, index|
          if (MaybeURI.new(val).uri?)
            value_array << MaybeURI.new(val).value
          else
            value_array << RDF::Literal(val, :language => form_params[:language][key][index]) unless form_params[:language][key].blank?
          end
        end
        new_hash[key] = value_array unless key == :language
      end
    end
    self.attributes = new_hash
  end
end
