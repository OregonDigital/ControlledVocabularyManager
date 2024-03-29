# frozen_string_literal: true

# Decorates set_languages
class SetsAttributes < SimpleDelegator
  def set_attributes(form_params)
    new_hash = {}
    attributes.each_pair do |key, value|
      if !blocklisted_language_properties.include?(key.to_sym)
        value_array = []
        value.each_with_index do |val, index|
          unless form_params['language'].nil?
            value_array << RDF::Literal(val, language: form_params['language'][key][index]) unless form_params['language'][key].blank?
          end
        end
        new_hash[key] = value_array if key != :language
      elsif uri_fields.include?(key.to_sym)
        value_array = []
        value.each do |val|
          # Don't raise error here, using validation in form is more helpful
          item = val.is_a?(ActiveTriples::Resource) ? val : new_resource(val)
          value_array << item
        end
        new_hash[key] = value_array
      else
        new_hash[key] = value
      end
    end
    self.attributes = new_hash
  end

  def new_resource(uri)
    resource = ActiveTriples::Resource.new(uri)
    resource.parent = self
    self.parent = nil
    resource
  end
end
