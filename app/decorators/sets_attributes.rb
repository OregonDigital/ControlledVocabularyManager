class SetsAttributes < SimpleDelegator
  def set_languages(form_params)
    new_hash = {}
    self.attributes.each_pair do |key, value|
      if !self.blacklisted_language_properties.include?(key.to_sym) 
        value_array = []
        value.each_with_index do |val, index|
          if !form_params[:language].nil?
            value_array << RDF::Literal(val, :language => form_params[:language][key][index]) unless form_params[:language][key].blank?
          else
    
          end
        end
        new_hash[key] = value_array unless key != :language
      else
        new_hash[key] = value
      end
    end
    (self.attributes.keys.map(&:to_sym) - form_params.keys).each { |key| new_hash[key] = [] }
    self.attributes = new_hash
  end
end
