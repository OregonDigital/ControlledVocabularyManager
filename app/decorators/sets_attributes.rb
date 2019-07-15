# frozen_string_literal: true

class SetsAttributes < SimpleDelegator
  def set_attributes(form_params)
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
      elsif self.uri_fields.include?(key.to_sym)
        value_array = []
        value.each_with_index do |val, index|
          item = ( val.is_a? ActiveTriples::Resource) ? val : RDF::URI(val) #Don't raise error here, using validation in form is more helpful
          value_array << item
        end
        new_hash[key] = value_array
      else
        new_hash[key] = value
      end
    end
    self.attributes = new_hash
  end
end
