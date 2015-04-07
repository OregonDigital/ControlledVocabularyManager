# Removes blank attributes from hashes in params.
class ParamCleaner
  def self.call(params)
    new(params).cleaned_params
  end

  pattr_initialize :params

  def cleaned_params
    params.each do |k,v|
      new_params[k] = clean_value(v)
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

