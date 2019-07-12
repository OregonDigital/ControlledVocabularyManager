# frozen_string_literal: true

# Removes blank attributes from hashes in params.
class ParamCleaner < Struct.new(:params)
  def self.call(params)
    new(params).cleaned_params
  end

  def cleaned_params
    params.each do |k, v|
      new_params[k] = clean_value(v) unless k == 'language'
    end
    new_params
  end

  private

  def clean_value(v)
    return v unless v.respond_to?(:reject)

    v.reject(&:blank?)
  end

  def new_params
    @new_params ||= {}.with_indifferent_access
  end
end
