class IsValidRdfString < ActiveModel::Validator
  def validate(record)
    if record.rdf_string.blank?
      record.errors.add(:rdf_string, "can't be blank") if record.rdf_string.blank?
      record.errors.add(:base, "RDF text cannot be blank.") if record.rdf_string.blank?
      return
    end
  end
end
