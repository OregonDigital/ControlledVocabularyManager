class ValidUri < ActiveModel::Validator

  def validate(record)
    record.uri_fields.each do |field|
      next if !record.respond_to? field || record.send(field).blank?
      record.send(field).each do |val|
        error = is_uri(val)
        record.errors[field] << error unless error.blank?
      end
    end
  end

  def is_uri(val)
    if val.is_a? ActiveTriples::Resource
      return "#{val} is not a valid URI" unless MaybeURI.new(val.rdf_subject.to_s).uri?
    elsif val.is_a? String
      return "#{val} is not a valid URI" unless MaybeURI.new(val).uri?
    end
  end
end