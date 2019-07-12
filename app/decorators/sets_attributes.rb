# frozen_string_literal: true

class SetsAttributes < SimpleDelegator
  def set_languages(form_params)
    new_hash = {}
    attributes.each_pair do |key, value|
      if !blacklisted_language_properties.include?(key.to_sym)
        value_array = []
        value.each_with_index do |val, index|
          unless form_params['language'].nil?
            value_array << RDF::Literal(val, language: form_params['language'][key][index]) unless form_params['language'][key].blank?
          end
        end
        new_hash[key] = value_array if key != :language
      else
        new_hash[key] = value
      end
    end
    self.attributes = new_hash
  end
end
